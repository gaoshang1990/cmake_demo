
#include "utils_log.h"
#include "version.h"


int main()
{
    slog_init(M_DEBUG, "./", "app.log");
    slog_app_info("demo", APP_FULL_VERSION);

    return 0;
}
