
cd mingw
cmake ../../ -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE:STRING=CMake/arm-gcc-toolchain.cmake
cmake --build .

pause
