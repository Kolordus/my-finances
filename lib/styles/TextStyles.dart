import 'dart:ui';

class TextStyles {

  static TextStyle getTextStyle(Color color, {double fontSize = 40}) {
    return TextStyle(fontSize: fontSize, color: color);
  }
}