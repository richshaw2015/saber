class Cfg {
  // 是否启用远程日志上传，测试阶段开启，上传商店时要关闭
  static const bool enableRemoteLog = true;

  static const double padding0 = 10.0;
  static const double padding = 12.0;
  static const double padding2 = 16.0;

  // 字体
  static const double fontLarge1 = 28.0;
  static const double fontLarge2 = 30.0;
  static const double fontLarge3 = 32.0;

  static const double fontTitleLarge = 21.0;
  static const double fontTitleMedium = 20.0;
  static const double fontTitleSmall = 19.0;

  static const double fontBodyLarge = 18.0;
  static const double fontBodyMedium = 17.0;
  static const double fontBodySmall = 16.0;

  static const double fontLabelLarge = 15.0;
  static const double fontLabelMedium = 14.0;
  static const double fontLabelSmall = 13.0;

  static const double lineHeight = 1.5;

  // 圆角
  static const radiusBtn = 5.0;

  // 工具入口尺寸，宽度为参考宽度，根据实际屏幕尺寸适配，以 390 屏幕宽度为基准
  static const phone2Width = 160.0;
  static const phone3Width = 108.0;
  static const phone4Width = 80.0;
  static const phone5Width = 66.0;
  static const phone6Width = 56.0;

  // 持久化
  static const settingAll = "setting_all";

  // 地址
  static const urlPrivacy = "https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=saber";
  static const urlAgreement = "https://www.superedu.app/agreement/saber";
  static const urlCrashlytics = "https://superedu.site:8000/crashlytics";
  static const urlRunLog = "https://superedu.site:8000/log";

  static const urlEmail = "mailto:saber@superedu.app";
}
