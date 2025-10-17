import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:saber/common/config.dart';
import 'package:saber/common/responsive.dart';


void showMyToast(BuildContext context, String message, Duration duration, bool bottom) {
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);

  // 创建动画控制器
  final controller = AnimationController(
    vsync: overlay,
    duration: const Duration(milliseconds: 400),
  );

  // 创建进度条动画控制器
  final progressController = AnimationController(
    vsync: overlay,
    duration: const Duration(milliseconds: 1200),
  );

  // 创建颜色渐变动画
  final colorTween = ColorTween(
    begin:  theme.colorScheme.primary.withAlpha(210),
    end:  theme.colorScheme.primary.withAlpha(240),
  );

  // 创建入场动画
  final slideAnimation = Tween<Offset>(
    begin: bottom ? const Offset(0, 1.0) : const Offset(0, -1.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.fastOutSlowIn,
  ));

  // 创建 Overlay 条目，提供两种样式，顶部和底部
  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: bottom ? null : Get.mediaQuery.padding.top + kToolbarHeight + Cfg.padding2,
        bottom: bottom ? MediaQuery.of(context).viewInsets.bottom + Cfg.padding2 : null,
        right: 0,
        left: 0,
        child: SlideTransition(
          position: slideAnimation,
          child: _content(
            colorTween: colorTween,
            message: message,
            animationController: progressController,
          ),
        ),
      );
    }
  );

  // 插入Overlay
  overlay.insert(overlayEntry);

  // 启动动画序列
  controller.forward().then((_) {
    // 启动进度条动画
    progressController.forward();

    // 3秒后移除Toast
    Future.delayed(duration, () {
      controller.reverse().then((_) {
        overlayEntry.remove();
        controller.dispose();
        progressController.dispose();
      });
    });
  });
}

// Toast内容组件
class _content extends StatelessWidget {
  final ColorTween colorTween;
  final AnimationController animationController;
  final String message;

  const _content({
    required this.message,
    required this.colorTween,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: RWD.toastPadding),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Cfg.radiusBtn),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorTween.transform(animationController.value)!,
                    colorTween.transform(animationController.value * 0.8)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
            ),
            padding: const EdgeInsets.all(Cfg.padding2),
            child: child,
          );
        },
        child: Text(
            message.tr,
            style: TextStyle(
              fontSize: Cfg.fontBodyLarge,
              color: Theme.of(context).colorScheme.onPrimary,
            )
        )
      ),
    );
  }
}
