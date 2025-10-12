import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/event.dart';
import '../model/setting.dart';

// 全局的事件处理
class G {
  static late final SharedPreferences _prefs;
  static late final Setting _setting;
  static late final PackageInfo _pkg;
  // static late final CacheService _cache;
  static late final EventBus _event;

  // 可选：对外只读 getter（如果你希望更“规范”）
  static SharedPreferences get prefs => _prefs;
  static Setting get setting => _setting;
  static PackageInfo get pkg => _pkg;
  // static CacheService get cache => _cache;
  static EventBus get event => _event;

  static Future<void> initGlobals() async {
    _prefs = await SharedPreferences.getInstance();
    _setting = Setting.fromPrefs();
    _pkg = await PackageInfo.fromPlatform();
    // _cache = CacheService();
    _event = EventBus();
  }

  // 自定义一个全局显示 toast 的方法
  static void toast(String msg, {Duration? duration, bool bottom = true}) {
    _event.fire(ShowToastEvent(msg, duration ?? 3.seconds, bottom));
  }
}
