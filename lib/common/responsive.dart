import 'dart:math' hide log;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'config.dart';

class RWD {
  // 目标适配最大尺寸
  static const double screenPhoneSize = 440.0;

  static const double _screenPad = 600.0;
  static const double _screenDesktop = 1000.0;

  // TODO 增加缓存
  static bool get isMobile => min(Get.width, Get.height) < _screenPad;
  static bool get isPad => min(Get.width, Get.height) >= _screenPad;
  static bool get isDesktop => min(Get.width, Get.height) >= _screenDesktop;

  // 判断设备尺寸
  static bool get isLarger376 => RWD.shortSide >= 376;
  static bool get isLess370 => RWD.shortSide < 370;

  static double get toastWidth => RWD.isLandscape
      ? 0.6*RWD.innerWidth
      : 0.8*RWD.innerWidth;
  static double get toastPadding => (innerWidth - toastWidth) * 0.5;

  // 只判断宽度
  static bool get isMobileWidth => Get.width < _screenPad;
  static bool get isPadWidth => Get.width >= _screenPad;
  static bool get isDesktopWidth => Get.width >= _screenDesktop;

  // 最小的屏幕宽度
  static double get shortSide => min(Get.width, Get.height);
  static double get longSide => max(Get.width, Get.height);
  // 最小屏幕宽度
  static double get short440 => min(shortSide, screenPhoneSize);

  //   // 判断是否为横屏
  static bool get isLandscape {
    return Get.mediaQuery.orientation == Orientation.landscape;
  }
  static bool get isPortrait {
    return Get.mediaQuery.orientation == Orientation.portrait;
  }

  static double get _axisThresholdMin => 1.08;
  static double get _axisThresholdMax => 1.3;

  // 可用的宽度、高度
  static double get innerWidth => Get.width - Get.mediaQuery.padding.left
      - Get.mediaQuery.padding.right;
  static double get innerHeight => Get.height - Get.mediaQuery.padding.top
      - Get.mediaQuery.padding.bottom;

  /// 根据设备返回不同的值
  static T rwdValue<T>(T mobile, [T? pad, T? desktop]) {
    if (isMobile) {
      return mobile;
    }

    if (isDesktop) {
      return desktop ?? pad ?? mobile;
    } else {
      return pad ?? mobile;
    }
  }
  /// 根据宽度返回不同的值
  static T rwdWidth<T>(T mobile, [T? pad, T? desktop]) {
    if (isMobileWidth) {
      return mobile;
    }

    if (isDesktopWidth) {
      return desktop ?? pad ?? mobile;
    } else {
      return pad ?? mobile;
    }
  }

  /// 自适应的区块数量
  static int rwdAxis(double blockWidth, {double? maxWidth, bool ensurePadding=true}) {
    double mediaPadding = Get.mediaQuery.padding.left + Get.mediaQuery.padding.right;
    double maxSize = maxWidth ??
        (ensurePadding
            ? Get.width - Cfg.padding - mediaPadding
            : Get.width - mediaPadding);

    // 避免间距过小，确保一定的间距
    int axis = maxSize ~/ blockWidth;

    if (ensurePadding && axis > 3) {
      for (var i=0; i<3; i++) {
        final ratio = maxSize / (axis * blockWidth);

        // 间距太大
        if (ratio > _axisThresholdMax) {
          if (maxSize / ((axis + 1) * blockWidth) > _axisThresholdMin) {
            axis += 1;
          } else {
            break;
          }
        }

        if (ratio < _axisThresholdMin) {
          if (maxSize / ((axis - 1) * blockWidth) < _axisThresholdMax) {
            axis -= 1;
          } else {
            break;
          }
        }
      }
    }
    return axis;
  }

  /// 自适应间距的尺寸
  static double rwdAxisSize(int axis, double spacing, {double? maxWidth,
    bool spaceEvenly=false}) {
    double mediaPadding = Get.mediaQuery.padding.left + Get.mediaQuery.padding.right;
    double maxSize = maxWidth ?? Get.width - mediaPadding;
    return (maxSize - (spaceEvenly ? axis + 1 : axis) *spacing) / axis;
  }

  // 根据屏幕返回一个线性尺寸，最小尺寸的基准是 360
  static double rwdLinearScreen(double minSize, double maxSize, {bool scale=true}) {
    double screen = RWD.shortSide;
    double target = (minSize * screen / 360).clamp(minSize, maxSize);
    if (!scale) {
      return target;
    } else {
      return RWD.rwdValue(target, 1.1*target, 1.2* target);
    }
  }

// // 获取屏幕尺寸
// static Size getScreenSize(BuildContext context) {
//   return MediaQuery.of(context).size;
// }
//
// // 获取状态栏高度
// static double getStatusBarHeight(BuildContext context) {
//   return MediaQuery.of(context).padding.top;
// }
//
// // 获取底部安全区域高度
// static double getBottomPadding(BuildContext context) {
//   return MediaQuery.of(context).padding.bottom;
// }
//
//
// // 根据横竖屏返回不同的值
// static T orientationValue<T>({
//   required BuildContext context,
//   required T portrait,
//   required T landscape,
// }) {
//   return isLandscape(context) ? landscape : portrait;
// }
//
// // 获取响应式边距
// static EdgeInsets getResponsivePadding(BuildContext context) {
//   return responsiveValue(
//     context: context,
//     mobile: EdgeInsets.all(16.0),
//     tablet: EdgeInsets.all(24.0),
//     desktop: EdgeInsets.all(32.0),
//   );
// }
//
// // 获取响应式字体大小
// static double getResponsiveFontSize(BuildContext context, {
//   double? baseSize,
//   double? mobileSize,
//   double? tabletSize,
//   double? desktopSize,
// }) {
//   final base = baseSize ?? 16.0;
//   return responsiveValue(
//     context: context,
//     mobile: mobileSize ?? base,
//     tablet: tabletSize ?? (base * 1.1),
//     desktop: desktopSize ?? (base * 1.2),
//   );
// }
//
// // 获取响应式列数
// static int getResponsiveColumns(BuildContext context, {
//   int? mobileColumns,
//   int? tabletColumns,
//   int? desktopColumns,
// }) {
//   return responsiveValue(
//     context: context,
//     mobile: mobileColumns ?? 1,
//     tablet: tabletColumns ?? 2,
//     desktop: desktopColumns ?? 3,
//   );
// }
//
//
// // 获取屏幕比例
// static double getAspectRatio(BuildContext context) {
//   final size = getScreenSize(context);
//   return size.width / size.height;
// }
}

// // 响应式构建器组件
// class ResponsiveBuilder extends StatelessWidget {
//   final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;
//
//   const ResponsiveBuilder({
//     Key? key,
//     required this.builder,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return builder(
//       context,
//       ResponsiveHelper.isMobile(context),
//       ResponsiveHelper.isTablet(context),
//       ResponsiveHelper.isDesktop(context),
//     );
//   }
// }

// // 横竖屏构建器组件
// class OrientationBuilder extends StatelessWidget {
//   final Widget Function(BuildContext context, Orientation orientation) builder;
//
//   const OrientationBuilder({
//     Key? key,
//     required this.builder,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return builder(
//       context,
//       MediaQuery.of(context).orientation,
//     );
//   }
// }