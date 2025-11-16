# 项目构建指南 📖

本文档详细说明了项目的构建过程、使用方法和开发工作流。

## 目录

- [项目架构](#项目架构)
- [快速开始](#快速开始)
- [构建配置](#构建配置)
- [构建流程详解](#构建流程详解)
- [单元测试](#单元测试)
- [代码质量](#代码质量)
- [常用场景](#常用场景)

---

## 项目架构 🏗️

本项目采用分层架构设计，包含三个主要层次：

```
项目根目录/
├── hal/              # Hardware Abstraction Layer (硬件抽象层)
│   ├── src/         # HAL源代码
│   ├── inc/         # HAL头文件
│   └── hal.mk       # HAL构建配置
├── sdk/              # Software Development Kit (软件开发包)
│   ├── component1/  # SDK组件1
│   ├── component2/  # SDK组件2
│   └── sdk.mk       # SDK构建配置
├── apps/             # Application Layer (应用程序层)
│   ├── app1/        # 应用程序1
│   └── app.mk       # APP构建配置
├── ut/               # Unit Test (单元测试)
├── build/            # 构建配置文件
│   ├── config/      # 配置文件模板
│   └── doxfile      # Doxygen配置
├── scripts/          # 构建脚本
│   ├── xmake.mk     # xmake构建系统
│   └── kconfiglib/  # 配置工具
└── output/           # 编译输出目录（自动生成）
    ├── hal/         # HAL编译产物
    ├── sdk/         # SDK编译产物
    ├── app/         # APP编译产物
    └── bin/         # 可执行文件
```

### 层次依赖关系

```
┌─────────┐
│   APP   │  应用程序层
└────┬────┘
     │ depends on
┌────▼────┐
│   SDK   │  软件开发包层
└────┬────┘
     │ depends on
┌────▼────┐
│   HAL   │  硬件抽象层
└─────────┘
```

---

## 快速开始 🚀

### 最简单的构建和运行流程

```bash
# 1. 生成配置文件
make config

# 2. 编译整个项目（包括 hal、sdk、app）
make

# 3. 运行应用程序
make app_run
```

### 查看帮助信息

```bash
make help
```

---

## 构建配置 ⚙️

### 配置管理

项目使用 Kconfig 风格的配置系统，支持三种配置方式：

#### 1. 使用默认配置

```bash
make config
```

- 读取配置文件：`build/global_config.config`（如果不存在则提示选择）
- 生成头文件：`/tmp/global_config.h`（默认路径）

#### 2. 选择指定配置

```bash
make config_choice
```

此命令会列出 `build/config/` 目录下的所有可用配置，供用户选择。

#### 3. 交互式配置（推荐）

```bash
make menuconfig
```

使用图形化界面（TUI）配置项目功能选项。

#### 自定义配置输出路径

```bash
# 将配置头文件生成到指定目录
make config CONFIG_PATH=/path/to/your/dir
```

### 构建选项

#### 库类型选择

```bash
# 编译静态库（默认）
make BUILD_STATIC=1

# 编译动态库
make BUILD_SHARED=1
```

**说明：**
- 静态库：生成 `.a` 文件，链接时代码会被嵌入到可执行文件中
- 动态库：生成 `.so` 文件，运行时动态加载

#### 单元测试模式

```bash
# 启用单元测试编译选项（添加调试符号和覆盖率信息）
make UT=1
```

---

## 构建流程详解 🔨

### 分层构建命令

#### 1. 编译 HAL 层

```bash
# 根据 BUILD_STATIC/BUILD_SHARED 自动选择
make hal

# 强制编译静态库
make hal_static

# 强制编译动态库
make hal_shared
```

**输出：**
- 静态库：`output/hal/lib/libhal.a`
- 动态库：`output/hal/lib/libhal.so`

#### 2. 编译 SDK 层

```bash
# 根据 BUILD_STATIC/BUILD_SHARED 自动选择
make sdk

# 强制编译静态库
make sdk_static

# 强制编译动态库
make sdk_shared
```

**输出：**
- 静态库：`output/sdk/lib/libsdk.a`
- 动态库：`output/sdk/lib/libsdk.so`

**注意：** SDK 的编译会自动依赖 HAL 层

#### 3. 编译应用程序

```bash
# 编译应用程序（会自动编译依赖的 hal 和 sdk）
make app

# 或者直接使用默认目标
make
```

**输出：**
- 可执行文件：`output/bin/$(APP_NAME)`

**注意：** `APP_NAME` 在 `apps/app.mk` 中定义

#### 4. 运行应用程序

```bash
make app_run
```

此命令会执行 `output/bin/$(APP_NAME)`

### 完整构建流程示意图

```
┌──────────────┐
│ make config  │  生成配置头文件
└──────┬───────┘
       │
┌──────▼───────┐
│  make hal    │  编译HAL层库
└──────┬───────┘
       │
┌──────▼───────┐
│  make sdk    │  编译SDK层库（链接HAL）
└──────┬───────┘
       │
┌──────▼───────┐
│  make app    │  编译应用程序（链接SDK和HAL）
└──────┬───────┘
       │
┌──────▼───────┐
│ make app_run │  运行应用程序
└──────────────┘
```

### 链接方式

#### 静态链接（BUILD_STATIC=1）

```bash
-L$(OUTPUT_HAL_DIR)/lib -L$(OUTPUT_SDK_DIR)/lib -lsdk -lhal
```

#### 动态链接（BUILD_SHARED=1）

```bash
$(OUTPUT_SDK_DIR)/lib/libsdk.so $(OUTPUT_HAL_DIR)/lib/libhal.so
```

---

## 单元测试 🧪

项目集成了完整的单元测试框架，支持测试、覆盖率统计和日志输出。

### 基本测试命令

```bash
# 准备测试环境
make ut_prepare

# 编译单元测试
make ut

# 编译并运行单元测试
make ut_run
```

### 高级测试选项

#### 生成覆盖率报告

```bash
# 运行测试并生成覆盖率报告
make ut_run COV=1
```

覆盖率报告会保存在 `ut/` 目录下。

#### 指定测试模块

```bash
# 只运行指定模块的测试
make ut_run TEST=module_name

# 运行指定模块并生成覆盖率
make ut_run TEST=led COV=1
```

#### 启用日志输出

```bash
# 运行测试并输出详细日志
make ut_run LOG=1

# 组合使用
make ut_run TEST=led COV=1 LOG=1
```

### 调试单元测试

```bash
# 启动单元测试调试模式
make ut_debug
```

### 清理测试产物

```bash
make clean_ut
```

### 自动化测试流程

```bash
# 快速自动化测试（清理+编译+测试+覆盖率）
make auto

# 等同于
make clean && make COV=1 TEST=led ut
```

---

## 代码质量 🔍

### 静态代码检查（cppcheck）

项目集成了 cppcheck 工具进行静态代码分析。

#### 检查所有 SDK 代码

```bash
make cppcheck
```

#### 检查指定模块

```bash
# 检查指定的SDK组件
make cppcheck CHECK=component_name
```

#### 输出日志到文件

```bash
# 将检查结果保存到 output/check/cppcheck.log
make cppcheck LOG=1
```

#### 检查规则

cppcheck 默认启用以下检查：
- `warning`: 警告级别的问题
- `style`: 代码风格问题
- `missingInclude`: 缺失的头文件

### 生成代码文档

```bash
# 使用 Doxygen 生成 HTML 文档
make doc
```

生成的文档位于 `output/` 目录下。

---

## 常用场景 💡

### 场景1：首次克隆项目后开始开发

```bash
# Step 1: 配置项目
make config

# Step 2: 编译项目
make

# Step 3: 运行应用验证
make app_run
```

### 场景2：修改代码后重新编译

```bash
# 如果只修改了 APP 层代码
make app

# 如果修改了 SDK 代码
make sdk && make app

# 如果修改了 HAL 代码（需要全部重新编译）
make clean && make
```

### 场景3：切换静态库/动态库

```bash
# 切换到静态库
make clean
make BUILD_STATIC=1

# 切换到动态库
make clean
make BUILD_SHARED=1
```

### 场景4：运行单元测试并查看覆盖率

```bash
# 完整的测试流程
make ut_run COV=1 LOG=1

# 指定模块测试
make ut_run TEST=your_module COV=1
```

### 场景5：代码静态检查

```bash
# 检查所有代码
make cppcheck

# 检查指定模块并输出日志
make cppcheck CHECK=module_name LOG=1
```

### 场景6：完整的开发工作流

```bash
# 1. 配置
make config

# 2. 开发代码
# ... 编写代码 ...

# 3. 静态检查
make cppcheck CHECK=your_module

# 4. 编译
make

# 5. 单元测试
make ut_run TEST=your_module COV=1

# 6. 运行应用
make app_run

# 7. 生成文档
make doc
```

### 场景7：持续集成（CI）流程

```bash
# 完整的CI流程脚本
make config && \
make cppcheck && \
make clean && \
make BUILD_STATIC=1 && \
make ut_run COV=1 && \
make doc
```

---

## 清理命令 🗑️

```bash
# 清理所有编译产物
make clean

# 只清理配置文件
make config_clean

# 只清理单元测试
make clean_ut
```

**注意：** `make clean` 会同时执行 `config_clean`，清理所有内容。

---

## 环境要求 📋

### 必需工具

- `make`: GNU Make 构建工具
- `gcc/g++`: GCC 编译器
- `python3`: Python 3.x（用于配置脚本）

### 可选工具

- `cppcheck`: 静态代码分析（如需使用 `make cppcheck`）
- `doxygen`: 文档生成（如需使用 `make doc`）
- `lcov`: 覆盖率报告生成（如需使用 `make ut_run COV=1`）

### 安装依赖（Ubuntu 示例）

```bash
# 安装必需工具
sudo apt-get update
sudo apt-get install -y build-essential python3

# 安装可选工具
sudo apt-get install -y cppcheck doxygen lcov
```

---

## 常见问题 ❓

### Q1: 执行 `make` 时提示找不到配置文件？

**A:** 首先运行 `make config` 生成配置文件。

### Q2: 如何查看当前使用的是静态库还是动态库？

**A:** 查看 Makefile 中的 `BUILD_STATIC` 和 `BUILD_SHARED` 变量：

```bash
make debug
```

### Q3: 单元测试失败怎么办？

**A:** 使用调试模式运行：

```bash
make ut_debug
```

### Q4: 如何添加新的 SDK 组件？

**A:**
1. 在 `sdk/` 目录下创建新组件目录
2. 在 `sdk/sdk.mk` 中添加组件的构建规则
3. 运行 `make sdk` 重新编译

### Q5: 覆盖率报告在哪里查看？

**A:** 运行 `make ut_run COV=1` 后，覆盖率报告位于 `ut/` 目录下，通常是 HTML 格式，可以用浏览器打开。

---

## 技术支持 📞

如有问题，请联系项目维护团队或查看项目仓库的 Issues。

---

**文档版本：** v1.0
**最后更新：** 2025-11-14
**维护者：** 项目开发团队
