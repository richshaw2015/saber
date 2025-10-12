import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

final isCanvasKit = js.globalContext['flutterCanvasKit'] != null;

// 检测是否运行在 WASM 环境
// Flutter 3.22+ 开始支持 WASM 编译目标
// 通过检测 dart:js_interop 是否可用来判断是否为 WASM
const bool kIsWasm = bool.fromEnvironment('dart.library.js_interop');

bool snapshotToImageSupportedInternal() {
  // CanvasKit 或 WASM 环境都支持快照
  return isCanvasKit || kIsWasm;
}
