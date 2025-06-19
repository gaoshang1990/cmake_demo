cmake_minimum_required (VERSION 3.16)

project(cmake_demo)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(utils_include)

make_version_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/src/app/version.h
)

recurse_auto_sources(user_files_c   "*.c"   "${CMAKE_CURRENT_SOURCE_DIR}/src" RELATIVE)
recurse_auto_sources(user_files_cpp "*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/src" RELATIVE)
recurse_auto_sources(user_files_h   "*.h"   "${CMAKE_CURRENT_SOURCE_DIR}/src" RELATIVE)
recurse_auto_sources(user_files_hpp "*.hpp" "${CMAKE_CURRENT_SOURCE_DIR}/src" RELATIVE)

if (MSVC)
    message(STATUS "Configuring for Win32")
    
    add_compile_options(/utf-8)
    add_definitions(-DTTUAPP_LIB_TEST)                                                               # 代码添加宏定义
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})  # 设置VS默认启动工程
    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/linux")             # 删除不需要的文件
    auto_source_group(source ./ ${user_files_c} ${user_files_cpp} ${user_files_h} ${user_files_hpp}) # vs工程目录结构
    add_compile_options(/wd4819)                                                                     # 忽略4819告警
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -NODEFAULTLIB:MSVCRT -SAFESEH:NO")

    recurse_auto_sources(user_files_lib "*.lib" "${CMAKE_CURRENT_SOURCE_DIR}/src/lib" RELATIVE)
    list(APPEND user_files_lib 
        legacy_stdio_definitions
    )
else()
    message(STATUS "Configuring for Linux")

    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/win32")
    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/pthread")

    recurse_auto_sources(user_files_lib "*.so" "${CMAKE_CURRENT_SOURCE_DIR}/src/lib" RELATIVE)
    recurse_auto_sources(user_files_lib "*.a"  "${CMAKE_CURRENT_SOURCE_DIR}/src/lib" RELATIVE)
    list(APPEND user_files_lib 
        pthread
        dl
    )
endif(MSVC)

find_files_dirs(user_dirs_lib "${user_files_lib}"                  RELATIVE)
find_files_dirs(user_dirs_inc "${user_files_h}; ${user_files_hpp}" RELATIVE)
list(APPEND user_dirs_inc "src/lib")
list(APPEND user_dirs_inc "src/third_party")

# 指定生成目标
add_executable(${PROJECT_NAME} ${user_files_c} ${user_files_cpp} ${user_files_h} ${user_files_hpp})

# 添加链接库, 库文件目录, 头文件目录
target_link_directories(${PROJECT_NAME}    PRIVATE ${user_dirs_lib})
target_link_libraries(${PROJECT_NAME}      PRIVATE ${user_files_lib})
target_include_directories(${PROJECT_NAME} PRIVATE ${user_dirs_inc})
