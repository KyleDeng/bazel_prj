# sdk/base/BUILD

# Define constants for reusability
CONFIG_FILE = "//build:global_config.config"
CONF2H_SCRIPT = "//scripts/kconfiglib:conf2h.py"

genrule(
    name = "gen_config",
    srcs = [CONFIG_FILE],
    outs = ["include/global_config.h"],
    tools = [CONF2H_SCRIPT],
    cmd = "python3 $(location {}) $(location {}) $@".format(CONF2H_SCRIPT, CONFIG_FILE),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "sdk_base",
    # hdrs = [":gen_config"],  # 这个写法不保险
    hdrs = ["include/global_config.h"],  # 使用某个目标的输出文件
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
)
