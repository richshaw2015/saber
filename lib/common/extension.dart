import 'package:saber/service/log/log.dart';
import 'package:url_launcher/url_launcher.dart';

extension StringExtension on String {

  // 通过第三方打开地址
  void launch() async {
    final Uri uri = Uri.parse(this);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Log.w("打开链接失败：$this");
    }
  }
}

