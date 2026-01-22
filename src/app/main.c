
#include <MQTTClient.h>

#include "utils_log.h"
#include "version.h"


int main()
{
    slog_init(M_DEBUG, "./", "app.log");
    slog_app_info("cmake_demo", APP_FULL_VERSION);

    MQTTClient _client;

    int rc = MQTTClient_create(&_client, "localhost:1883", "test_id", MQTTCLIENT_PERSISTENCE_NONE, NULL);
    if (rc != MQTTCLIENT_SUCCESS) {
        slog_error("failed to create client, return code %d", rc);
    }
    else {
        slog_info("MQTT client created successfully");
    }


    return 0;
}
