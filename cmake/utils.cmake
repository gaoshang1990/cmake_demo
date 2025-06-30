# 绝对路径转成相对路径
function(path_to_relative ret_)
    set(relative_paths_ "")

    foreach(path_ ${ARGN})
        # 获取相对于项目根目录的路径
        if(IS_ABSOLUTE "${path_}")
            file(RELATIVE_PATH relative_file_ "${CMAKE_CURRENT_SOURCE_DIR}" "${path_}")
            list(APPEND relative_paths_ "${relative_file_}")
        else()
            list(APPEND relative_paths_ "${path_}")
        endif()
    endforeach()

    set(${ret_} ${relative_paths_} PARENT_SCOPE)
endfunction(path_to_relative)

# 相对路径转成绝对路径
function(path_to_absolute ret_)
    set(abs_paths_ "")

    foreach(path_ ${ARGN})
        if(NOT IS_ABSOLUTE "${path_}")
            get_filename_component(abs_path "${CMAKE_CURRENT_SOURCE_DIR}/${path_}" ABSOLUTE)
            list(APPEND abs_paths_ "${abs_path}")
        else()
            list(APPEND abs_paths_ "${path_}")
        endif()
    endforeach()

    set(${ret_} ${abs_paths_} PARENT_SCOPE)
endfunction(path_to_absolute)

# 自动收集源文件
# ret:      若 ret 已经存在, 则会将收集到的源文件追加到 ret 中
# pattern:  匹配的文件模式
# dir:      指定的目录, 递归查找
# RELATIVE: 可选参数，指定时返回相对路径，否则返回绝对路径
function(recurse_auto_sources ret_ pattern_ dir_)
    path_to_absolute(dir_ ${dir_}) # 确保 dir_ 是绝对路径

    file(GLOB subdir_files_ "${dir_}/${pattern_}")
    list(APPEND ${ret_} ${subdir_files_})

    file(GLOB subdirs_ RELATIVE ${dir_} ${dir_}/*)

    foreach(sub_ ${subdirs_})
        if (IS_DIRECTORY ${dir_}/${sub_})
            if (NOT "${sub_}" STREQUAL "CMakeFiles")
                file(GLOB_RECURSE subdir_files_ "${dir_}/${sub_}/${pattern_}")
                list(APPEND ${ret_} ${subdir_files_})
            endif()
        endif()
    endforeach()

    if("RELATIVE" IN_LIST ARGN)
        path_to_relative(${ret_} ${${ret_}})
    endif()
    
    set(${ret_} ${${ret_}} PARENT_SCOPE)
endfunction(recurse_auto_sources)

# Remove all files matching a set of patterns, and,
# optionally, not matching a second set of patterns,
# from a set of lists.
#
# Example:
# This will remove all files in the CPP_SOURCES list
# matching "/test/" or "Test.cpp$", but not matching
# "BobTest.cpp$".
# remove_matches_from_lists(CPP_SOURCES MATCHES "/test/" "Test.cpp$" IGNORE_MATCHES "BobTest.cpp$")
#
# Parameters:
#
# [...]:
# The names of the lists to remove matches from.
#
# [MATCHES ...]:
# The matches to remove from the lists.
#
# [IGNORE_MATCHES ...]:
# The matches not to remove, even if they match
# the main set of matches to remove.
function(remove_matches_from_lists)
    set(LISTS_TO_SEARCH)
    set(MATCHES_TO_REMOVE)
    set(MATCHES_TO_IGNORE)
    set(argumentState 0)
    foreach (arg ${ARGN})
        if ("x${arg}" STREQUAL "xMATCHES")
            set(argumentState 1)
        elseif ("x${arg}" STREQUAL "xIGNORE_MATCHES")
            set(argumentState 2)
        elseif (argumentState EQUAL 0)
            list(APPEND LISTS_TO_SEARCH ${arg})
        elseif (argumentState EQUAL 1)
            list(APPEND MATCHES_TO_REMOVE ${arg})
        elseif (argumentState EQUAL 2)
            list(APPEND MATCHES_TO_IGNORE ${arg})
        else()
            message(FATAL_ERROR "Unknown argument state!")
        endif()
    endforeach()

    foreach (theList ${LISTS_TO_SEARCH})
        foreach (entry ${${theList}})
            foreach (match ${MATCHES_TO_REMOVE})
                if (${entry} MATCHES ${match})
                    set(SHOULD_IGNORE OFF)
                    foreach (ign ${MATCHES_TO_IGNORE})
                        if (${entry} MATCHES ${ign})
                            set(SHOULD_IGNORE ON)
                            break()
                        endif()
                    endforeach()

                    if (NOT SHOULD_IGNORE)
                        list(REMOVE_ITEM ${theList} ${entry})
                    endif()
                endif()
            endforeach()
        endforeach()
        set(${theList} ${${theList}} PARENT_SCOPE)
    endforeach()
endfunction()

# 返回文件所在目录
# ret:      返回的目录列表
# files:    文件列表
# RELATIVE: 可选参数，指定时返回相对路径，否则返回绝对路径
function(find_files_dirs ret files)
    foreach(file_ ${files})
        if(NOT IS_ABSOLUTE "${file_}")
            get_filename_component(file_ "${CMAKE_CURRENT_SOURCE_DIR}/${file_}" ABSOLUTE)
        endif()

        get_filename_component(dir_ ${file_} DIRECTORY)
        if (EXISTS "${dir_}")
            if(RETURN_RELATIVE)
                # 转换为相对路径
                file(RELATIVE_PATH rel_dir_ "${CMAKE_CURRENT_SOURCE_DIR}" "${dir_}")
                list(APPEND ${ret} ${rel_dir_})
            else()
                list(APPEND ${ret} ${dir_})
            endif()
        endif()
    endforeach()

    # 去除重复的路径
    if(${ret})
        list(REMOVE_DUPLICATES ${ret})
    endif()

    if("RELATIVE" IN_LIST ARGN)
        path_to_relative(${ret} ${${ret}})
    endif()

    set(${ret} ${${ret}} PARENT_SCOPE)
endfunction(find_files_dirs ret files)


# Automatically create source_group directives for the sources passed in.
function(auto_source_group rootName rootDir)
    file(TO_CMAKE_PATH "${rootDir}" rootDir)
    string(LENGTH "${rootDir}" rootDirLength)
    set(sourceGroups)
    foreach (fil ${ARGN})
        file(TO_CMAKE_PATH "${fil}" filePath)
        string(FIND "${filePath}" "/" rIdx REVERSE)
        if (rIdx EQUAL -1)
        message(FATAL_ERROR "Unable to locate the final forward slash in '${filePath}'!")
        endif()
        string(SUBSTRING "${filePath}" 0 ${rIdx} filePath)

        string(LENGTH "${filePath}" filePathLength)
        string(FIND "${filePath}" "${rootDir}" rIdx)
        if (rIdx EQUAL 0)
        math(EXPR filePathLength "${filePathLength} - ${rootDirLength}")
        string(SUBSTRING "${filePath}" ${rootDirLength} ${filePathLength} fileGroup)

        string(REPLACE "/" "\\" fileGroup "${fileGroup}")
        set(fileGroup "\\${rootName}${fileGroup}")

        list(FIND sourceGroups "${fileGroup}" rIdx)
        if (rIdx EQUAL -1)
            list(APPEND sourceGroups "${fileGroup}")
            # message(STATUS "Adding source group: ${fileGroup}")
            source_group("${fileGroup}" REGULAR_EXPRESSION "${filePath}/[^/.]+.(cpp|h|c)$")
        endif()
        endif()
    endforeach()
endfunction()


# 从文件路径中提取不带扩展名的文件名
# ret:   返回值变量名，存储处理后的文件名列表
# ARGN:  输入的文件路径列表，支持以下格式：
#        - 完整路径: "src/lib/utils/utils.lib" -> "utils"
#        - 相对路径: "utils/helper.lib" -> "helper"  
#        - 文件名:   "math.lib" -> "math"
# 示例: extract_base_names(lib_names "src/lib/utils/utils.lib" "math.lib")
#       结果: lib_names = ["utils", "math"]
function(files_base_name ret)
    set(names_without_ext "")
    
    foreach(file_path ${ARGN})
        if(file_path)  # 跳过空字符串
            get_filename_component(name_we ${file_path} NAME_WE)
            if(name_we)  # 确保提取到了有效的文件名
                list(APPEND names_without_ext ${name_we})
            endif()
        endif()
    endforeach()
    
    set(${ret} ${names_without_ext} PARENT_SCOPE)
endfunction(files_base_name)

# 智能处理 debug/release 库名，支持 sad/sad.lib、sa/sa.lib 等特殊情况
# 支持传入带路径或不带路径的库名（如 src/lib/utils/utils.lib、utilsd.lib）
# 用法：smart_link_libraries(ret_ lib1 lib2 ...)
# 结果：ret_ 为生成器表达式拼接后的库列表
function(libs_debug_release ret_)
    set(processed_bases_ "")
    set(ret_libs_ "")
    
    # 第一步：识别所有可能的基础名
    set(potential_bases_ "")
    foreach(lib ${ARGN})
        get_filename_component(lib_name_we_ ${lib} NAME_WE)
        
        # 检查是否以'd'结尾
        string(REGEX MATCH "(.+)d$" match_result_ ${lib_name_we_})
        if(match_result_)
            # 以'd'结尾，提取基础名
            string(REGEX REPLACE "d$" "" base_ ${lib_name_we_})
            list(APPEND potential_bases_ ${base_})
        else()
            # 不以'd'结尾，本身就是基础名
            list(APPEND potential_bases_ ${lib_name_we_})
        endif()
    endforeach()
    
    # 去重基础名
    list(REMOVE_DUPLICATES potential_bases_)
    
    # message(STATUS "Potential base names: ${potential_bases_}")
    
    # 第二步：对每个基础名进行处理
    foreach(base_ ${potential_bases_})
        # 跳过已处理的基础名
        list(FIND processed_bases_ ${base_} found_idx_)
        if(NOT found_idx_ EQUAL -1)
            continue()
        endif()
        
        set(has_release_ 0)
        set(has_debug_   0)
        set(release_lib_ "")
        set(debug_lib_   "")
        
        # 查找对应的release和debug版本
        foreach(lib_ ${ARGN})
            get_filename_component(lib_name_we_ ${lib_} NAME_WE)
            
            if("${lib_name_we_}" STREQUAL "${base_}")
                set(has_release_ 1)
                set(release_lib_ "${lib_}")
            endif()
            
            if("${lib_name_we_}" STREQUAL "${base_}d")
                set(has_debug_ 1)
                set(debug_lib_ "${lib_}")
            endif()
        endforeach()
        
        # 根据找到的版本添加到结果中
        if(has_release_ AND has_debug_)
            # 同时有release和debug版本
            list(APPEND ret_libs_ 
                "$<$<CONFIG:Debug>:${debug_lib_}>" 
                "$<$<NOT:$<CONFIG:Debug>>:${release_lib_}>")
            # message(STATUS "Found pair: ${base_} -> Debug: ${debug_lib_}, Release: ${release_lib_}")
        elseif(has_release_)
            # 只有release版本
            list(APPEND ret_libs_ ${release_lib_})
            # message(STATUS "Found release only: ${release_lib_}")
        elseif(has_debug_)
            # 只有debug版本（实际上可能不是真正的debug版本）
            list(APPEND ret_libs_ ${debug_lib_})
            # message(STATUS "Found debug only: ${debug_lib_}")
        endif()
        
        # 标记已处理
        list(APPEND processed_bases_ ${base_})
    endforeach()
    
    set(${ret_} ${ret_libs_} PARENT_SCOPE)
endfunction(libs_debug_release)

# 测试函数
function(test_libs_debug_release)
    message(STATUS "\n=== Testing libs_debug_release ===")

    # 测试用例1：标准的debug/release对
    set(test_libs1 
        "lib/libopencvd.a" 
        "lib/libopencv.a"
        "lib/libboostd.a"
        "lib/libboost.a"
    )
    
    message(STATUS "\nTest 1 - Standard debug/release pairs:")
    message(STATUS "Input: ${test_libs1}")
    libs_debug_release(result1 ${test_libs1})
    message(STATUS "Output: ${result1}")
    
    # 测试用例2：包含单独的以'd'结尾的库
    set(test_libs2
        "lib/libcurld.so"
        "lib/libcurl.so" 
        "lib/libsad.so"      # 只有这个，不应被视为debug
        "lib/libxml2.so"
    )
    
    message(STATUS "\nTest 2 - Mixed with standalone 'd' ending:")
    message(STATUS "Input: ${test_libs2}")
    libs_debug_release(result2 ${test_libs2})
    message(STATUS "Output: ${result2}")
    
    # 测试用例3：只有debug版本
    set(test_libs3
        "lib/libonlydebugd.a"
        "lib/libregular.a"
    )
    
    message(STATUS "\nTest 3 - Only debug versions:")
    message(STATUS "Input: ${test_libs3}")
    libs_debug_release(result3 ${test_libs3})
    message(STATUS "Output: ${result3}")
    
    message(STATUS "=== End of tests ===\n")
endfunction()

