<p align="center">
  <h1 align="center"> <code>flutter_keyboard_visibility</code> </h1>
</p>


本项目基于 [flutter_keyboard_visibility@6.0.0](https://pub.dev/packages/flutter_keyboard_visibility/versions/6.0.0) 开发。

## 1. 安装与使用

### 1.1 安装方式

进入到工程目录并在 pubspec.yaml 中添加以下依赖：

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  flutter_keyboard_visibility:
    git:
      url: https://gitcode.com/openharmony-sig/flutter_keyboard_visibility.git
      path: "flutter_keyboard_visibility"
```

执行命令

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 使用案例

使用案例详见 [ohos/example](./flutter_keyboard_visibility/example/)

## 2. 约束与限制

### 2.1 兼容性

在以下版本中已测试通过

1. Flutter: 3.7.12-ohos-1.0.6; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| KeyboardVisibilityController | [KeyboardVisibilityHandler](#KeyboardVisibilityHandler) | 提供有关键盘可见性的直接信息并允许您订阅更改。 | function | yes               |
| KeyboardVisibilityWidget(child: widget, onKeyboardVisibilityChanged: (bool visible) {}) | widget | 一个widget的构建器，用于显示本机键盘是否可见。 | function | yes               |

## 4. 属性

> [!TIP] "ohos Support"列为 yes 表示 ohos 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

## KeyboardVisibilityHandler

> 

| Name                              | return       | Description                                         | Type     | ohos Support |
| --------------------------------- | ------------ | --------------------------------------------------- | -------- | ------------ |
| onchange.listen((bool visile) {}) | Stream<bool> | 每次显示键盘时发出 true，每次关闭键盘时发出 false。 | function | yes          |



## 4. 遗留问题

无

## 5. 其他

## 6. 开源协议

本项目基于 [MIT开源协议](https://gitcode.com/openharmony-sig/flutter_keyboard_visibility/blob/master/LICENSE) ，请自由地享受和参与开源。



> 模板版本: v0.0.1