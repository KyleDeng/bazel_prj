# bazel使用

## 安装

[参考文档](https://bazel.build/versions/8.2.0/install/ubuntu?hl=zh-cn)

安装命令：

```shell
sudo apt install apt-transport-https curl gnupg -y
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
sudo mv bazel-archive-keyring.gpg /usr/share/keyrings
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt update && sudo apt install bazel
bazel --version
```


## 使用

### 入门

[官方教程](https://bazel.build/versions/8.0.0/start/cpp?hl=zh-cn)

[常见C++使用场景](https://bazel.build/tutorials/cpp-use-cases?hl=zh-cn)

### 文件说明

> BUILD文件：声明构建目标
>
> 定义要构建什么，要求尽量简洁、声明式、无逻辑
>
> 放在构建单元的目录中

> .bzl文件：定义逻辑和复用机制
>
> 定义如何构建，提供宏、自定义规则、工具函数等
>
> 一般放在tools、build目录中

> MODULE.bazel：依赖管理 、配置文件
>
> MODULE.bazel 告诉 Bazel：“这个项目是谁、依赖哪些外部模块、用什么版本”。
>
> 它相当于：
>
> Node.js 的 package.json
>
> Go 的 go.mod

### 常用命令

```shell
bazel build  ## 构建
bazel run    ## 运行目标
bazel clean  ## 清理

# 测试相关
bazel test      # 单元测试
bazel coverage  # 覆盖率

# 依赖
bazel query    # 查看依赖
bazel cquery   # 考虑配置后的依赖

# 其他
bazel version   # 版本
bazel info      # 显示环境信息
bazel shutdown  # 关闭后台服务进程
bazel init      # 初始化项目
bazel sync      # 同步外部依赖
bazel fetch     # 下载依赖

```

### 单元测试 🧪

项目使用 Google Test 框架进行单元测试，通过 Bazel 进行管理和运行。

#### 运行测试

```shell
# 运行所有 SDK 模块的测试
bazel test //sdk/...

# 运行单个模块的测试
bazel test //sdk/led/ut:led_test
bazel test //sdk/key/ut:key_test

# 显示所有测试输出（包括成功的测试）
bazel test //sdk/led/ut:led_test --test_output=all

# 只显示失败的测试输出
bazel test //sdk/... --test_output=errors

# 实时显示测试输出
bazel test //sdk/... --test_output=streamed
```

#### 过滤和控制测试

```shell
# 运行特定的测试用例（使用 gtest_filter）
bazel test //sdk/led/ut:led_test --test_arg=--gtest_filter="TestLedInit.*"

# 重复运行测试多次
bazel test //sdk/led/ut:led_test --test_arg=--gtest_repeat=3

# 运行被禁用的测试
bazel test //sdk/led/ut:led_test --test_arg=--gtest_also_run_disabled_tests

# 显示测试执行时间
bazel test //sdk/... --test_arg=--gtest_print_time=1
```

#### 调试测试

```shell
# 使用 gdb 调试测试
bazel test //sdk/led/ut:led_test --run_under=gdb

# 使用 valgrind 检测内存问题
bazel test //sdk/led/ut:led_test --run_under=valgrind

# 详细模式（显示编译命令和测试输出）
bazel test //sdk/led/ut:led_test -s --test_output=all
```

#### 测试覆盖率

```shell
# 收集单个模块的覆盖率（包含源代码覆盖率）
bazel coverage //sdk/led/ut:led_test \
    --combined_report=lcov \
    --instrumentation_filter="//sdk/led[/:]"

# 收集所有 SDK 模块的覆盖率
bazel coverage //sdk/... \
    --combined_report=lcov \
    --instrumentation_filter="//sdk/...[/:]"

# 生成 HTML 可视化报告
genhtml bazel-out/_coverage/_coverage_report.dat \
    -o coverage_html \
    --title "SDK Coverage Report"

# 在浏览器中打开报告
explorer.exe coverage_html/index.html

# 或使用快捷脚本（推荐）
./scripts/coverage.sh //sdk/...
```

**覆盖率文件位置：**
- LCOV 数据：`bazel-out/_coverage/_coverage_report.dat`
- HTML 报告：`coverage_html/index.html`

**查看覆盖率摘要：**
```shell
# 查看文本摘要
lcov --summary bazel-out/_coverage/_coverage_report.dat
```


#### 与 Makefile 命令对照

| Make 命令 | Bazel 等价命令 | 说明 |
|-----------|---------------|------|
| `make ut` | `bazel build //sdk/...` | 构建测试 |
| `make ut_run` | `bazel test //sdk/...` | 运行所有测试 |
| `make ut_run TEST=led` | `bazel test //sdk/led/ut:led_test` | 运行指定模块测试 |
| `make ut_run FILTER="TestLedInit.*"` | `bazel test //sdk/led/ut:led_test --test_arg=--gtest_filter="TestLedInit.*"` | 过滤测试用例 |
| `make ut_run GDB=1` | `bazel test //sdk/led/ut:led_test --run_under=gdb` | 调试测试 |
| `make ut_run COV=1` | `bazel coverage //sdk/...` | 收集覆盖率 |

#### 测试依赖

项目的单元测试依赖以下框架：

- **Google Test** - 单元测试框架（通过 MODULE.bazel 管理）
- **Google Mock** - Mock 框架（Google Test 自带）
- **mockcpp** - C++ Mock 库（位于 `ut/externals/mockcpp/`）

```

### 生成依赖图

```shell
# 结果中包含全部内容，工具链、操作系统等等
bazel query 'deps(//main:hello-world)' --output graph > deps.dot

# 只保留源码的，但是lib的依赖也没有了
bazel query "kind('source file', deps(//main:hello-world))" --notool_deps --output=graph > file_deps.dot

# 过滤工具，仅显示依赖，比较简洁
bazel query "deps(//main:hello-world)" --noimplicit_deps --notool_deps --output=graph > file_deps.dot

# 查看反向依赖
bazel query "rdeps(//main:hello-world)" --output=graph > file_rdeps.dot
```

使用`dot`工具生成图片

```shell
dot -Tpng file_deps.dot -o my_app_deps.png
```

## 关于python

Bazel并不是使用python语言，而是Starlark语言（https://github.com/bazelbuild/starlark）

有些语法比较相似但不完全一致


## 关于menuconfig

Bazel在构建过程中不允许这种不确定的过程出现
