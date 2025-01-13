#include <stdio.h>

#define FMT_HEADER_ONLY
#include <fmt/core.h>

#include "version.h"


int main()
{
    fmt::print("Version: {}\n", APP_FULL_VERSION);

    printf("Hello, World!\n");

    fmt::print("Hello, World!\n");

    return 0;
}
