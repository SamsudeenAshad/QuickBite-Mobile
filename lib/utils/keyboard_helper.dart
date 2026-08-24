import 'package:flutter/services.dart';

void showSoftKeyboard() {
  SystemChannels.textInput.invokeMethod<void>('TextInput.show');
}
