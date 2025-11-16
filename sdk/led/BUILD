# sdk/led/BUILD

cc_library(
    name = "led_lib",
    srcs = glob(["src/*.c"]),
    hdrs = glob(["include/*.h"]),
    includes = ["include"],
    deps = [
        "//sdk/base:sdk_base",  # 依赖SDK Base的相关头文件
        "//hal:hal_lib",  # 依赖hal的相关头文件
    ],
    visibility = ["//visibility:public"],
)
