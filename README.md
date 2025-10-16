# saber

template project for ohos projects

## Commands

Fluter Documentation: https://gitcode.com/openharmony-tpc/flutter_flutter

### 创建工程
```
# 创建全新项目
flutter322 create --platforms ohos <projectName>
# 新增平台支持
flutter create --platforms=ios .
```

## 快速开始模板项目
- 准备 App 的 logo、名称、包名
- 去 AppGallery Connect 后台新增一个 App /项目，包括 App ID
- 拷贝工程，清理中间的 Build 文件
- 替换应用 Package name，【com.example.ohos_genesis】 ->
- 替换关键字 【ohos_genesis】 -> ，注意安卓工程的路径 android/app/src/main/kotlin/com/example/calendar/MainActivity.kt
- 替换应用名称【今日宜忌】 ->
- 替换 logo 文件，可以从 src/logo.png 通过脚本生成
    - ohos/entry/src/main/resources/base/media/startIcon.png 128X128
    - ohos/entry/src/ohosTest/resources/base/media/startIcon.png 和上述一样
    - assets/images/logo.webp 192X192
    - ohos/AppScope/resources/base/media/foreground.png  1024X024
- 签名配置 ohos/build-profile.json5，每个应用的签名都不一样，后台创建一个发布的 profile
- 其他模块配置，权限、支持平台、打开文件等

### Build
通过 flutter devices 指令发现 ohos 设备之后，使用 hdc -t <deviceId> install <hap file path> 进行安装。

```
# for cloud debug
flutter322 build hap --target-platform ohos-arm64 --release
# for app store release
flutter322 build app --release --target-platform ohos-arm64
```
