cmake 示例工程。

## 编译说明

### Windows

VS 默认编译64位程序：

```bat
cd win32
cmake ../../ -G "Visual Studio 17 2022"
cmake --build .

pause
```

若需要编译32位程序，请使用以下命令：

```bat
cd win32
cmake ../../ -G "Visual Studio 17 2022" -A "Win32"
cmake --build .

pause
```

### Linux

```bash
cd linux
cmake ../../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE:STRING=cmake/arm-gcc-toolchain.cmake
cmake --build .

cd ..
```

### minGW

```bat
cd mingw
cmake ../../ -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE:STRING=CMake/arm-gcc-toolchain.cmake
cmake --build .

pause
```
