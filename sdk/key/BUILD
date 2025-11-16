# sdk/key/BUILD

cc_library(
    name = "key_lib",
    srcs = glob(["src/*.c"]),
    hdrs = glob(["include/*.h"]),
    includes = ["include"],
    deps = [
        "//sdk/led:led_lib",  # key中用到了led的头文件
        "//sdk/base:sdk_base",
        "//hal:hal_lib",
    ],
    visibility = ["//visibility:public"],
)
