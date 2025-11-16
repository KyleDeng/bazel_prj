# hal/BUILD

cc_library(
    name = "hal_lib",
    srcs = glob(["src/*.c"]),
    hdrs = glob(["include/*.h"]),
    includes = ["include"],  # 添加 include 目录到搜索路径
    visibility = ["//visibility:public"],  # 允许其他包使用
)

