# super_native_extensions 编译和使用指南

## 1. 环境要求

### 必需工具
- **Rust 1.82+**（当前使用 1.90.0）
- **Cargo**（Rust 包管理器）
- **Android NDK**（用于 Android 平台）
- **Flutter 3.22+**

### 安装 Rust（如果未安装）

```bash
# 通过 rustup 安装（推荐）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 或通过 Homebrew（macOS）
brew install rustup-init
rustup-init
```

### 安装 Android 目标

```bash
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add i686-linux-android
rustup target add x86_64-linux-android
```

## 2. 环境配置

### 设置环境变量

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Android NDK（根据你的实际路径调整）
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/28.0.13004108

# 确保使用 rustup 的 Rust（而不是 Homebrew 的）
export PATH="$HOME/.cargo/bin:$PATH"
```

应用配置：

```bash
source ~/.zshrc  # 或 source ~/.bashrc
```

## 3. 项目结构

```
packages/super_native_extensions/
├── super_clipboard/              # 剪贴板功能
├── super_context_menu/           # 上下文菜单
├── super_drag_and_drop/          # 拖放功能
├── super_hot_key/                # 热键支持
├── super_keyboard_layout/        # 键盘布局
└── super_native_extensions/      # 核心库
    ├── rust/                     # Rust 原生代码
    │   ├── Cargo.toml           # Rust 依赖配置
    │   ├── src/                 # Rust 源代码
    │   └── cargokit.yaml        # CargoKit 配置
    ├── android/                  # Android 平台实现
    ├── ios/                      # iOS 平台实现
    ├── macos/                    # macOS 平台实现
    ├── windows/                  # Windows 平台实现
    ├── linux/                    # Linux 平台实现
    └── ohos/                     # OpenHarmony 平台实现
```

## 4. 编译步骤

### 4.1 测试 Rust 编译

```bash
cd packages/super_native_extensions/super_native_extensions/rust
cargo check
```

### 4.2 构建 Android 版本

```bash
# 回到项目根目录
cd /Users/neo/HarmonyProjects/saber

# 清理之前的构建
flutter322 clean

# 构建 APK
flutter322 build apk --debug
```

### 4.3 构建其他平台

```bash
# iOS
flutter322 build ios

# macOS
flutter322 build macos

# Windows
flutter322 build windows

# Linux
flutter322 build linux
```

## 5. 在 pubspec.yaml 中使用

### 使用本地路径（开发时）

```yaml
dependencies:
  super_clipboard:
    path: packages/super_native_extensions/super_clipboard
```

### 使用 Git 仓库（生产环境）

```yaml
dependencies:
  super_clipboard:
    git:
      url: "https://gitcode.com/openharmony-sig/fluttertpc_super_native_extensions.git"
      path: "super_clipboard"
      ref: br_v0.9.1_ohos
```

## 6. 功能模块说明

### super_clipboard
剪贴板访问，支持：
- 读写文本
- 读写图片
- 读写富文本
- 读写文件

```dart
import 'package:super_clipboard/super_clipboard.dart';

// 写入文本
final clipboard = SystemClipboard.instance;
final item = DataWriterItem();
item.add(Formats.plainText('Hello World'));
await clipboard?.write([item]);

// 读取文本
final reader = await clipboard?.read();
if (reader != null && reader.canProvide(Formats.plainText)) {
  final text = await reader.readValue(Formats.plainText);
  print(text);
}
```

### super_context_menu
上下文菜单（右键菜单）

### super_drag_and_drop
拖放功能支持

### super_hot_key
全局热键注册

### super_keyboard_layout
键盘布局检测

## 7. 常见问题

### 问题 1: `rustc 1.80.1 is not supported`

**解决方案**：升级 Rust

```bash
rustup update
rustc --version  # 确认版本 >= 1.82
```

### 问题 2: `ANDROID_NDK_HOME not set`

**解决方案**：设置环境变量

```bash
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/28.0.13004108
```

### 问题 3: CargoKit 编译失败

**解决方案**：确保使用 rustup 的 Rust

```bash
which rustc  # 应该输出 ~/.cargo/bin/rustc
export PATH="$HOME/.cargo/bin:$PATH"
```

### 问题 4: `Flutter plugin not found`

**解决方案**：这是警告，不影响编译。如果需要修复，在 `android/build.gradle` 中移除：

```gradle
subprojects {
    project.evaluationDependsOn(":app")  // 删除这行
}
```

## 8. 性能优化

### 减少编译时间

在 `~/.cargo/config.toml` 中添加：

```toml
[build]
jobs = 8  # 根据你的 CPU 核心数调整

[target.aarch64-linux-android]
linker = "aarch64-linux-android21-clang"

[target.armv7-linux-androideabi]
linker = "armv7a-linux-androideabi21-clang"

[target.i686-linux-android]
linker = "i686-linux-android21-clang"

[target.x86_64-linux-android]
linker = "x86_64-linux-android21-clang"
```

### 使用共享构建缓存

```bash
export CARGO_BUILD_TARGET_DIR=~/.cargo/build_cache
```

## 9. 调试技巧

### 查看 Rust 编译日志

```bash
cd packages/super_native_extensions/super_native_extensions/rust
RUST_LOG=debug cargo build --verbose
```

### 查看 Android 构建日志

```bash
cd android
./gradlew :super_native_extensions:assembleDebug --info
```

### 检查生成的库文件

```bash
find android/build -name "*.so" | grep super_native
```

## 10. 更新依赖

### 更新 Rust 依赖

```bash
cd packages/super_native_extensions/super_native_extensions/rust
cargo update
```

### 更新 Flutter 依赖

```bash
flutter322 pub upgrade
```

## 11. 参考资源

- [super_native_extensions GitHub](https://github.com/superlistapp/super_native_extensions)
- [CargoKit 文档](https://github.com/irondash/cargokit)
- [Rust FFI 指南](https://doc.rust-lang.org/nomicon/ffi.html)
- [Flutter 插件开发](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
