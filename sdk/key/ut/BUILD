# sdk/key/ut/BUILD

# Unit tests for KEY module

cc_test(
    name = "key_test",
    srcs = glob(["test/*.cpp"]),
    deps = [
        "//sdk/key:key_lib",
        "//sdk/led:led_lib",  # key tests depend on led
        "//sdk/base:sdk_base",
        "//hal:hal_lib",
        "//ut:mockcpp",
        "@googletest//:gtest",
        "@googletest//:gtest_main",
    ],
    size = "small",
)
