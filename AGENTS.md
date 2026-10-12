# AGENTS.md

本文件为 AI 编程助手（OpenCode / GitHub Copilot 等）在本仓库中工作时提供指引。

## 项目概述

`cmake_demo` 是一个跨平台 C/C++ CMake 模板工程，支持 Windows(MSVC)、MinGW 交叉编译（aarch64-linux）、Android(arm64) 和 Linux。通过 CMakePresets 驱动构建，依赖经 vcpkg 管理（eclipse-paho-mqtt-c），并自带预编译静态库 utils4c（日志、FIFO、链表等 C 工具库）。版本号由 git 提交数自动生成。

## 仓库结构

```
.
├── CMakeLists.txt          # 主工程文件：源文件自动收集、库/头文件目录处理
├── CMakePresets.json       # 构建预设：win32 / mingw / android / linux
├── cmake/
│   ├── includes.cmake      # 引入 utils.cmake 与 git.cmake
│   ├── utils.cmake         # 通用 CMake 函数（自动收集源文件、debug/release 库处理等）
│   ├── git.cmake           # 从 git 提取版本信息（make_version_file）
│   └── version.h.in        # 版本头文件模板
├── script/
│   ├── clean.bat           # 清理编译中间产物（.d/.obj/.o/.sln/.vcxproj 等）
│   └── make_version.bat    # 手动生成 src/app/version.h
├── src/
│   ├── app/
│   │   ├── main.c          # 程序入口
│   │   └── version.h       # 【生成文件】勿手动修改，构建时自动生成
│   └── lib/                # 预编译库（头文件入库，.lib/.a 二进制不入库）
│       └── utils4c/        # utils4c 静态库：utils4c.lib / utils4cd.lib / libutils4c.a + 头文件
├── new_c_project.py        # 基于本模板快速创建新工程的脚本
└── .vscode/                # VSCode 任务、调试与 C/C++ 配置
```

## 环境要求

- CMake ≥ 3.26（presets 需要），CMakeLists 最低要求 3.16
- 环境变量 `VCPKG_ROOT` 指向 vcpkg 安装目录（win32/mingw/android 预设必需）
- Windows 本机编译：Visual Studio 2022
- Android 交叉编译：环境变量 `ANDROID_NDK_ROOT`
- Git（版本号生成依赖 `find_package(Git REQUIRED)`）

## 构建命令

统一使用 CMakePresets（不要再用 README 中已过时的 `cd win32; cmake ../../` 方式）：

```powershell
# Windows x64（需先设置 VCPKG_ROOT）
cmake --preset win32
cmake --build --preset win32-debug    # Debug
cmake --build --preset win32-release  # Release

# Linux（Unix Makefiles，Release）
cmake --preset linux
cmake --build build/linux

# MinGW 交叉编译 aarch64-linux
cmake --preset mingw
cmake --build --preset mingw

# Android arm64（需 ANDROID_NDK_ROOT）
cmake --preset android
cmake --build --preset android
```

VSCode 任务（`.vscode/tasks.json`）封装了以上命令：`cmake_win32` / `build_win32d` / `build_win32` / `cmake_mingw` / `build_mingw` / `cmake_android` / `build_android` / `make_version` / `clean` / `mkdir`。

其他常用操作：

```powershell
# 清理中间产物（保留 CMake 缓存）——唯一的清理方式
script/clean.bat

# 单独重新生成版本文件（默认输出到 script/ 目录，或传参指定目录）
script/make_version.bat <输出目录>
```

> **禁止事项：** 永远不要执行 `Remove-Item` / `del` / `rmdir` 删除 `build/` 下的任何目录（如 `build/win32`）。即使需要完全重新配置，也只能提示并**由用户手动删除**。

## 版本号机制

- `src/app/version.h` 是**生成文件**（已在 .gitignore 中），由 CMake configure 阶段调用 `make_version_file()`（cmake/git.cmake）从 git 提交数生成：`MAJOR = count/1000`，`MINOR = count/100 % 10`，`PATCH = count%100`。
- 修改提交后重新 configure（或运行 `make_version.bat`）即可刷新版本；`main.c` 通过 `APP_FULL_VERSION` 使用它。
- **不要手动编辑 `src/app/version.h`**。

## 代码规范（摘自 .Github/copilot-instructions.md）

**C/C++ 源码（.c/.h/.cpp/.hpp）：**
- 注释使用 `/* */` 块注释，内容用英文
- 缩进 4 个空格
- 变量与函数：`snake_case`；类名：`CamelCase`；常量/宏：`UPPER_SNAKE_CASE`
- 头文件卫哨风格：`_UTILS_LOG_H___`；C 库头文件保留 `extern "C"` 包裹

**CMake 脚本：** 函数/宏注释可用中文（现有 cmake/*.cmake 均如此）

**终端操作：** 使用 PowerShell，命令间用 `;` 连接；与用户对话使用中文

## 开发约定

### 源码管理（重要）
- `src/` 下所有 `.c`/`.cpp`/`.h`/`.hpp` 会被 `recurse_auto_sources` **自动递归收集**，新增源文件无需改 CMakeLists，放入即编译。
- 平台专属代码按目录名过滤（`remove_matches_from_lists`）：
  - MSVC 下会剔除路径含 `/linux` 的文件
  - 非 MSVC（Linux/MinGW/Android）下会剔除路径含 `/win32` 和 `/pthread` 的文件
  - 例：`src/app/linux/xxx.c` 仅在 Linux 构建时参与编译
- VS 工程目录结构由 `auto_source_group` 自动生成，与磁盘目录一致。

### 预编译库管理
- 库放在 `src/lib/<库名>/` 下，头文件入 git；二进制（.lib/.a）被 .gitignore（各机器本地放置）。
- **debug/release 成对命名约定**：Release 库名为 `<name>`，Debug 库名为 `<name>d`（如 `utils4c.lib` / `utils4cd.lib`）。`libs_debug_release` 会据此生成条件链接。
- Windows 链接 MSVCRT：`-NODEFAULTLIB:MSVCRT -SAFESEH:NO`，并使用 `/MTd`(Debug) `/MT`(Release) 静态运行时。
- 新增第三方头文件搜索目录已被 `src/lib`、`src/third_party` 覆盖。

### 第三方依赖
- `eclipse-paho-mqtt-c` 经 vcpkg + `find_package(eclipse-paho-mqtt-c CONFIG REQUIRED)` 查找，自动适配 `paho-mqtt3c` 或 `-static` 目标。
- `utils4c` 提供日志 API：`slog_init(level, dir, file)`、`slog_info/slog_error(...)` 等宏，日志级别 `M_TRACE/M_DEBUG/M_INFO/M_WARN/M_ERROR`，详见 `src/lib/utils4c/utils_log.h`。

### 测试
- 当前**没有单元测试**。`CMakePresets.json` 中的 testPresets 只是预设占位（`noTestsAction: ignore`）。
- 修改后的验证方式为实际构建；如需添加测试，可引入 CTest 并补充对应 preset。

## 注意事项

- **严禁删除 `build/` 下的任何目录或 CMake 缓存文件。** 清理构建产物只能执行 `script/clean.bat`（仅删除 .d/.obj/.o/.sln/.vcxproj 等中间产物）。若必须完全重新配置，只能提示用户，**由用户手动删除** `build/<preset>` 目录后重新运行 `cmake --preset <preset>`。
- `README.md` 中的编译说明**已过时**（引用了不存在的 `cmake/arm-gcc-toolchain.cmake` 和旧目录方式），以本文档的 preset 命令为准。
- `build/` 下所有产物均被 gitignore，不需要提交。
- 复制本模板创建新工程：运行 `python new_c_project.py`，会提示输入项目名并自动替换 `CMakeLists.txt`、`main.c`、`.vscode/launch.json` 中的 `cmake_demo`。
- 修改 `CMakePresets.json` 或 `cmake/` 下的脚本后，务必在目标平台实际 configure + build 验证，presets 有平台 condition（如 win32 仅 Windows 生效）。
