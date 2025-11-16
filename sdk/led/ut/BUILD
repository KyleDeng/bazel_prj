# sdk/led/ut/BUILD

# Unit tests for LED module

cc_test(
    name = "led_test",
    srcs = glob(["test/*.cpp"]),
    deps = [
        "//sdk/led:led_lib",
        "//sdk/base:sdk_base",
        "//hal:hal_lib",
        "//ut:mockcpp",
        "@googletest//:gtest",
        "@googletest//:gtest_main",
    ],
    size = "small",
)
