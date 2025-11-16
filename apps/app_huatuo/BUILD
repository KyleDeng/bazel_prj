# apps/app_huatuo/BUILD

cc_binary(
    name = "app_huatuo",
    srcs = glob([
        "src/*.c",
        "include/*.h"  # 内部使用的头文件
    ]),
    # hdrs = glob(["include/*.h"]),  # bin产物不被依赖，不需要导出头文件
    includes = ["include"],
    deps = [
        "//sdk:sdk_lib",
    ],
)
