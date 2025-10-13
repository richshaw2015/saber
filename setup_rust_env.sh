#!/bin/bash

# 设置 Android NDK 路径
export ANDROID_NDK_HOME=~/Library/Android/sdk/ndk/28.0.13004108

# 设置 Rust 环境
export CARGO_BUILD_TARGET_DIR=~/.cargo/build_cache

# 验证环境
echo "✅ Rust 版本:"
rustc --version

echo ""
echo "✅ Cargo 版本:"
cargo --version

echo ""
echo "✅ Android NDK:"
echo "   $ANDROID_NDK_HOME"

echo ""
echo "✅ Rust Android 目标:"
rustup target list --installed | grep android

echo ""
echo "🔧 环境变量已设置，可以开始编译了"
