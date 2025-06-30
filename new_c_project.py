import os
import shutil
import re

DEFAULT_BASE_DIR = r"D:/dev"

def input_nonempty(prompt):
    while True:
        val = input(prompt).strip()
        if val:
            return val

def copy_project(src_dir, dst_dir):
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
    for root, dirs, files in os.walk(src_dir):
        # 跳过 build 目录和 .git 目录
        if 'build' in dirs:
            dirs.remove('build')
        if '.git' in dirs:
            dirs.remove('.git')
        rel_path = os.path.relpath(root, src_dir)
        target_root = os.path.join(dst_dir, rel_path) if rel_path != '.' else dst_dir
        if not os.path.exists(target_root):
            os.makedirs(target_root)
        for file in files:
            # 跳过 new_c_project.py
            if file == 'new_c_project.py':
                continue
            src_file = os.path.join(root, file)
            dst_file = os.path.join(target_root, file)
            shutil.copy2(src_file, dst_file)

def replace_in_file(filepath, old, new):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    content_new = re.sub(re.escape(old), new, content)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content_new)

def main():
    src_dir = os.path.abspath(os.path.dirname(__file__))
    project_name = input_nonempty("请输入新项目名称：")
    dst_dir_input = input("请输入新项目目录, 可为绝对或相对路径(相对 D:/dev): ").strip()
    if not dst_dir_input:
        dst_dir = os.path.abspath(os.path.join(DEFAULT_BASE_DIR, project_name))
    elif os.path.isabs(dst_dir_input):
        dst_dir = os.path.abspath(os.path.join(dst_dir_input, project_name))
    else:
        dst_dir = os.path.abspath(os.path.join(DEFAULT_BASE_DIR, dst_dir_input, project_name))

    # 复制文件
    copy_project(src_dir, dst_dir)
    print(f"已复制到 {dst_dir}")

    # 创建 build/mingw、build/linux、build/win32 目录
    build_dirs = [os.path.join(dst_dir, 'build', sub) for sub in ['mingw', 'linux', 'win32']]
    for d in build_dirs:
        os.makedirs(d, exist_ok=True)
    print("已创建 build/mingw、build/linux、build/win32 目录")

    # 替换 CMakeLists.txt
    cmake_path = os.path.join(dst_dir, "CMakeLists.txt")
    if os.path.exists(cmake_path):
        replace_in_file(cmake_path, "cmake_demo", project_name)
        print("已替换 CMakeLists.txt 中的项目名")

    # 替换 main.cpp
    main_cpp_path = os.path.join(dst_dir, "src", "app", "main.c")
    if os.path.exists(main_cpp_path):
        replace_in_file(main_cpp_path, "cmake_demo", project_name)
        print("已替换 main.c 中的项目名")

    # 替换 .vscode/launch.json
    launch_path = os.path.join(dst_dir, ".vscode", "launch.json")
    if os.path.exists(launch_path):
        replace_in_file(launch_path, "cmake_demo", project_name)
        print("已替换 launch.json 中的项目名")

if __name__ == "__main__":
    main()
