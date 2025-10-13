# Cargo Build 与 Flutter Build 集成流程详解

## 1. Cargo Build 的编译产物

### 1.1 产物类型

根据 `Cargo.toml` 中的配置：

```toml
[lib]
crate-type = ["cdylib", "staticlib"]
```

生成两种类型的库：

#### cdylib (C Dynamic Library)
- **Android**: `libsuper_native_extensions.so`
- **macOS**: `libsuper_native_extensions.dylib`
- **Windows**: `super_native_extensions.dll`
- **Linux**: `libsuper_native_extensions.so`

#### staticlib (Static Library)
- **所有平台**: `libsuper_native_extensions.a`

### 1.2 产物位置

```
rust/target/
├── debug/                              # Debug 构建
│   ├── libsuper_native_extensions.a
│   ├── libsuper_native_extensions.dylib  (macOS)
│   └── deps/                           # 依赖库
│
├── release/                            # Release 构建
│   ├── libsuper_native_extensions.a
│   ├── libsuper_native_extensions.dylib
│   └── deps/
│
└── <target-triple>/                    # 交叉编译目标
    ├── aarch64-linux-android/
    │   ├── debug/
    │   │   └── libsuper_native_extensions.so
    │   └── release/
    │       └── libsuper_native_extensions.so
    ├── armv7-linux-androideabi/
    ├── i686-linux-android/
    └── x86_64-linux-android/
```

### 1.3 Android 各架构的产物

```bash
# ARM 64位 (现代手机)
target/aarch64-linux-android/release/libsuper_native_extensions.so

# ARM 32位 (老旧手机)
target/armv7-linux-androideabi/release/libsuper_native_extensions.so

# x86 64位 (模拟器)
target/x86_64-linux-android/release/libsuper_native_extensions.so

# x86 32位 (老旧模拟器)
target/i686-linux-android/release/libsuper_native_extensions.so
```

## 2. Flutter Build 触发 Cargo 编译的完整流程

### 2.1 流程图

```
flutter build apk
    ↓
Gradle 构建系统启动
    ↓
读取 android/build.gradle
    ↓
应用 CargoKit Gradle 插件
    ↓
CargoKit 创建构建任务 (CargoKitBuildTask)
    ↓
执行 run_build_tool.sh
    ↓
动态生成临时 Dart 项目
    ↓
编译并运行 build_tool (Dart)
    ↓
build_tool 调用 rustup + cargo
    ↓
Cargo 编译 Rust 代码
    ↓
生成 .so 文件
    ↓
CargoKit 复制 .so 到 jniLibs
    ↓
Gradle 打包 APK
    ↓
完成
```

### 2.2 详细步骤

#### 步骤 1: Gradle 读取插件配置

**文件**: `android/build.gradle`

```gradle
apply from: "../cargokit/gradle/plugin.gradle"

cargokit {
    manifestDir = "../rust"        // Rust 代码位置
    libname = "super_native_extensions"  // 库名
}
```

#### 步骤 2: CargoKit 创建构建任务

**文件**: `cargokit/gradle/plugin.gradle`

```gradle
class CargoKitBuildTask extends DefaultTask {
    @TaskAction
    def build() {
        // 执行 run_build_tool.sh
        project.exec {
            executable path
            args "build-gradle"
            environment "CARGOKIT_MANIFEST_DIR", manifestDir
            environment "CARGOKIT_CONFIGURATION", buildMode
            environment "CARGOKIT_TARGET_PLATFORMS", targetPlatforms
            environment "CARGOKIT_NDK_VERSION", ndkVersion
            // ... 更多环境变量
        }
    }
}
```

**传递的环境变量**:
- `CARGOKIT_ROOT_PROJECT_DIR`: 项目根目录
- `CARGOKIT_MANIFEST_DIR`: Cargo.toml 所在目录
- `CARGOKIT_CONFIGURATION`: debug 或 release
- `CARGOKIT_TARGET_PLATFORMS`: arm64-v8a,armeabi-v7a,x86_64,x86
- `CARGOKIT_NDK_VERSION`: NDK 版本号
- `CARGOKIT_OUTPUT_DIR`: 输出目录 (jniLibs)

#### 步骤 3: run_build_tool.sh 动态生成 Dart 项目

**文件**: `cargokit/run_build_tool.sh`

```bash
# 在临时目录创建 pubspec.yaml
cat << EOF > "pubspec.yaml"
name: build_tool_runner
dependencies:
  build_tool:
    path: "$BUILD_TOOL_PKG_DIR"
EOF

# 创建入口文件
cat << EOF > "bin/build_tool_runner.dart"
import 'package:build_tool/build_tool.dart' as build_tool;
void main(List<String> args) {
  build_tool.runMain(args);
}
EOF

# 编译 Dart 代码
dart compile kernel bin/build_tool_runner.dart

# 运行编译好的 Dart 工具
dart bin/build_tool_runner.dill build-gradle
```

#### 步骤 4: build_tool 解析环境变量并调用 Cargo

**文件**: `cargokit/build_tool/lib/src/builder.dart`

```dart
Future<String> _build(Target target, List<String> extraArgs) async {
  final manifestPath = path.join(environment.manifestDir, 'Cargo.toml');
  
  runCommand(
    'rustup',
    [
      'run',
      _toolchain,  // 例如: stable
      'cargo',
      'build',
      '--manifest-path', manifestPath,
      '-p', environment.crateInfo.packageName,
      '--release',  // 如果是 release 模式
      '--target', target.rust,  // 例如: aarch64-linux-android
      '--target-dir', environment.targetTempDir,
    ],
    environment: await _buildEnvironment(),
  );
}
```

**_buildEnvironment() 设置的环境变量**:

```dart
// 对于 Android
{
  'CARGO_BUILD_TARGET': 'aarch64-linux-android',
  'CC': '$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang',
  'CXX': '$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android21-clang++',
  'AR': '$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar',
  'RANLIB': '$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ranlib',
  'CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER': '...-clang',
}
```

#### 步骤 5: Cargo 执行实际编译

**实际执行的命令**:

```bash
rustup run stable cargo build \
  --manifest-path /path/to/rust/Cargo.toml \
  -p super_native_extensions \
  --release \
  --target aarch64-linux-android \
  --target-dir /path/to/build/cargokit_target
```

**Cargo 的工作**:
1. 解析 `Cargo.toml` 依赖
2. 下载 crates.io 上的依赖（首次）
3. 编译所有依赖库
4. 编译主 crate
5. 链接生成 `.so` 文件

#### 步骤 6: CargoKit 复制产物到 jniLibs

**文件**: `cargokit/build_tool/lib/src/build_gradle.dart`

```dart
// 复制编译产物到 Android jniLibs 目录
final outputDir = environment.outputDir;  // android/src/main/jniLibs
final targetDir = await builder.build(target, []);

// 复制 .so 文件
File(path.join(targetDir, 'libsuper_native_extensions.so'))
  .copySync(path.join(outputDir, target.android, 'libsuper_native_extensions.so'));
```

**最终产物位置**:

```
android/src/main/jniLibs/
├── arm64-v8a/
│   └── libsuper_native_extensions.so
├── armeabi-v7a/
│   └── libsuper_native_extensions.so
├── x86_64/
│   └── libsuper_native_extensions.so
└── x86/
    └── libsuper_native_extensions.so
```

#### 步骤 7: Gradle 打包 APK

Gradle 将 `jniLibs` 中的 `.so` 文件打包进 APK：

```
app.apk
└── lib/
    ├── arm64-v8a/
    │   └── libsuper_native_extensions.so
    ├── armeabi-v7a/
    │   └── libsuper_native_extensions.so
    ├── x86_64/
    │   └── libsuper_native_extensions.so
    └── x86/
        └── libsuper_native_extensions.so
```

## 3. 构建任务的触发时机

### 3.1 Gradle 任务依赖关系

```
:app:assembleDebug
    ↓
:app:mergeDebugJniLibFolders
    ↓
:super_native_extensions:buildCargoDebug[Arm64-v8a]
:super_native_extensions:buildCargoDebug[Armeabi-v7a]
:super_native_extensions:buildCargoDebug[X86_64]
:super_native_extensions:buildCargoDebug[X86]
    ↓
(并行执行 Cargo 编译)
```

### 3.2 增量构建

CargoKit 会检查：
1. **Rust 源代码是否变化** (通过 hash)
2. **Cargo.toml 是否变化**
3. **依赖是否变化**

如果没有变化，跳过编译，直接使用缓存的 `.so` 文件。

## 4. 手动触发 Cargo 编译

### 4.1 直接使用 Cargo

```bash
cd packages/super_native_extensions/super_native_extensions/rust

# 编译 macOS 本地版本
cargo build --release

# 编译 Android ARM64
cargo build --release --target aarch64-linux-android

# 编译所有 Android 架构
for target in aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android; do
  cargo build --release --target $target
done
```

### 4.2 通过 Flutter 触发

```bash
# 完整构建（包括 Rust）
flutter build apk --debug

# 只构建特定架构
flutter build apk --debug --target-platform android-arm64

# 清理后重新构建
flutter clean
cd android && ./gradlew clean
flutter build apk --debug
```

### 4.3 只编译 Rust 部分

```bash
cd android
./gradlew :super_native_extensions:buildCargoDebugArm64-v8a
```

## 5. 调试技巧

### 5.1 查看 Cargo 编译日志

```bash
# 在 Flutter 构建时查看详细日志
flutter build apk --debug --verbose 2>&1 | grep -A 10 "cargo build"
```

### 5.2 查看生成的 .so 文件

```bash
# 查看编译产物
find android/build -name "*.so" | grep super_native

# 查看 .so 文件信息
file android/src/main/jniLibs/arm64-v8a/libsuper_native_extensions.so

# 查看 .so 导出的符号
nm -D android/src/main/jniLibs/arm64-v8a/libsuper_native_extensions.so | grep -i super
```

### 5.3 强制重新编译

```bash
# 清理 Cargo 缓存
cd packages/super_native_extensions/super_native_extensions/rust
cargo clean

# 清理 Gradle 缓存
cd android
./gradlew clean
./gradlew :super_native_extensions:clean

# 清理 Flutter 缓存
flutter clean

# 重新构建
flutter build apk --debug
```

## 6. 性能优化

### 6.1 使用共享构建缓存

在 `~/.cargo/config.toml` 中：

```toml
[build]
target-dir = "/Users/neo/.cargo/build_cache"
```

### 6.2 并行编译

```toml
[build]
jobs = 8  # 根据 CPU 核心数调整
```

### 6.3 使用 sccache

```bash
# 安装 sccache
cargo install sccache

# 配置
export RUSTC_WRAPPER=sccache
```

## 7. 常见问题

### 问题 1: 找不到 NDK

**错误**: `ANDROID_NDK_HOME not set`

**解决**:
```bash
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/28.0.13004108
```

### 问题 2: Rust 版本不兼容

**错误**: `rustc 1.80.1 is not supported`

**解决**:
```bash
rustup update
rustc --version  # 确认版本
```

### 问题 3: 链接器错误

**错误**: `ld: library not found for -lc++`

**解决**: 确保 NDK 路径正确，并且设置了正确的 CC/CXX 环境变量。

### 问题 4: 编译太慢

**优化**:
1. 使用 `--release` 模式（虽然慢但只编译一次）
2. 使用 sccache 缓存
3. 减少不必要的依赖
4. 使用增量编译（Cargo 默认开启）

## 8. 总结

**Cargo 编译产物**: `.so` (Android), `.dylib` (macOS), `.dll` (Windows), `.a` (静态库)

**触发流程**: Flutter → Gradle → CargoKit → run_build_tool.sh → build_tool (Dart) → Cargo

**关键文件**:
- `android/build.gradle` - 引入 CargoKit
- `cargokit/gradle/plugin.gradle` - Gradle 插件
- `cargokit/run_build_tool.sh` - Shell 脚本
- `cargokit/build_tool/` - Dart 构建工具
- `rust/Cargo.toml` - Rust 项目配置

**产物位置**: `android/src/main/jniLibs/<arch>/lib<name>.so`
