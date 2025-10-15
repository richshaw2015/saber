<p align="center">
  <h1 align="center"> <code>flutter_keyboard_visibility</code> </h1>
</p>


This project is based on [flutter_keyboard_visibility@6.0.0](https://pub.dev/packages/flutter_keyboard_visibility/versions/6.0.0).

## 1. Installation and Usage

### 1.1 Installation

Go to the project directory and add the following dependencies in pubspec.yaml

<!-- tabs:start -->

#### pubspec.yaml

```yaml
dependencies:
  flutter_keyboard_visibility:
    git:
      url: https://gitcode.com/openharmony-sig/flutter_keyboard_visibility.git
      path: "flutter_keyboard_visibility"
```

Execute Command

```bash
flutter pub get
```

<!-- tabs:end -->

### 1.2 Usage

For use cases [ohos/example](./flutter_keyboard_visibility/example/)

## 2. Constraints

### 2.1 Compatibility

This document is verified based on the following versions:

1. Flutter: 3.7.12-ohos-1.1.1; SDK: 5.0.0(12); IDE: DevEco Studio: 5.0.13.200; ROM: 5.1.0.120 SP3;

## 3. API

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name                | return          | Description                                                                                                             | Type     | ohos Support |
|---------------------|-------------------------------------------------------------------------------------------------------------------------|----------|-------------------|-------------------|
| KeyboardVisibilityController                                 | [KeyboardVisibilityHandler](#KeyboardVisibilityHandler) | Provides direct information about keyboard visibility and allows youto subscribe to changes. | function | yes          |
| KeyboardVisibilityWidget(child: widget, onKeyboardVisibilityChanged: (bool visible) {}) | widget                                                  | A convenience builder that exposes if the native keyboard is visible. | function | yes          |

## 4. Properties

> [!TIP] If the value of **ohos Support** is **yes**, it means that the ohos platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

## KeyboardVisibilityHandler

| Name                              | return       | Description                                                  | Type     | ohos Support |
| --------------------------------- | ------------ | ------------------------------------------------------------ | -------- | ------------ |
| onchange.listen((bool visile) {}) | Stream<bool> | Emits true every time the keyboard is shown, and false every time the keyboard is dismissed. | function | yes          |



## 5. Known Issues

not

## 6. Others

## 7. License

This project is licensed under  [MIT License](https://gitcode.com/openharmony-sig/flutter_keyboard_visibility/blob/master/LICENSE) .

> Template version: v0.0.1