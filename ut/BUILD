# ut/BUILD

# Unit testing external dependencies and utilities

# Mock C++ library for unit testing
cc_library(
    name = "mockcpp",
    hdrs = glob(["externals/mockcpp/include/**/*.h",
                 "externals/mockcpp/include/**/*.hpp",
                 "externals/mockcpp/include/**/*.tcc"]),
    srcs = ["externals/mockcpp/lib/libmockcpp.a"],
    includes = ["externals/mockcpp/include"],
    visibility = ["//visibility:public"],
)
