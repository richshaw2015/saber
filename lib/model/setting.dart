import 'dart:convert';

import 'package:flutter/material.dart';

import '../common/config.dart';
import '../common/constant.dart';

class Setting {
  // 主题，取 ThemeMode 的 index
  int theme;

  Setting({required this.theme});

  factory Setting.fromMap(Map<String, dynamic> map) {
    return Setting(
      theme: map['theme'] ?? ThemeMode.system.index,
    );
  }

  factory Setting.fromPrefs() {
    final value = G.prefs.getString(Cfg.settingAll);
    return Setting.fromMap(value == null ? {} : jsonDecode(value));
  }
}
