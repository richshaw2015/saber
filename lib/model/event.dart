
// 发送 toast 消息
class ShowToastEvent {
  String message;
  Duration duration;
  bool bottom;
  ShowToastEvent(this.message, this.duration, this.bottom);
}
