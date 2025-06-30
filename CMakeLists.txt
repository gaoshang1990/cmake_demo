cmake_minimum_required (VERSION 3.16)

project(cmake_demo)

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/includes.cmake)

make_version_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/version.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/src/app/version.h
)

recurse_auto_sources(user_files_c   "*.c"   "src" RELATIVE)
recurse_auto_sources(user_files_cpp "*.cpp" "src" RELATIVE)
recurse_auto_sources(user_files_h   "*.h"   "src" RELATIVE)
recurse_auto_sources(user_files_hpp "*.hpp" "src" RELATIVE)

if(MSVC)
    message(STATUS "Configuring for Win32")
    
    add_compile_options(/utf-8)
    add_compile_options(/wd4819)
    add_compile_options("$<$<CONFIG:Debug>:/MTd>" "$<$<CONFIG:Release>:/MT>")
    set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})  # 设置VS默认启动工程
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -SAFESEH:NO")
    
    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/linux")             # 删除不需要的文件
    auto_source_group(source ./ ${user_files_c} ${user_files_cpp} ${user_files_h} ${user_files_hpp}) # vs工程目录结构

    recurse_auto_sources(user_files_lib "*.lib" "src/lib")
    find_files_dirs(user_dirs_lib "${user_files_lib}") # 放在提取文件名之前
    libs_debug_release(user_files_lib ${user_files_lib})

else()
    message(STATUS "Configuring for Linux")

    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/win32")
    remove_matches_from_lists(user_files_c user_files_cpp user_files_h MATCHES "/pthread")

    recurse_auto_sources(user_files_lib "*.so" "src/lib") # linux 库使用绝对路径, 不然下面的链接不好处理
    recurse_auto_sources(user_files_lib "*.a"  "src/lib")
    libs_debug_release(user_files_lib ${user_files_lib})
    find_files_dirs(user_dirs_lib "${user_files_lib}" RELATIVE)
    list(APPEND user_files_lib 
        pthread
        dl
    )
endif(MSVC)

find_files_dirs(user_dirs_inc "${user_files_h}; ${user_files_hpp}" RELATIVE)
list(APPEND user_dirs_inc "src/lib")
list(APPEND user_dirs_inc "src/third_party")

# 指定生成目标
add_executable(${PROJECT_NAME}
    ${user_files_c}
    ${user_files_cpp}
    ${user_files_h}
    ${user_files_hpp}
)

# 添加链接库, 库文件目录, 头文件目录
target_link_directories(${PROJECT_NAME}    PRIVATE ${user_dirs_lib})
target_link_libraries(${PROJECT_NAME}      PRIVATE ${user_files_lib})
target_include_directories(${PROJECT_NAME} PRIVATE ${user_dirs_inc})
