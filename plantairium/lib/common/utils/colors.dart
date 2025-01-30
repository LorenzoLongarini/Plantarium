import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const Map<int, Color> primarySwatch = {
  50: Color.fromARGB(255, 46, 100, 66),
  100: Color.fromARGB(255, 46, 100, 66),
  200: Color.fromARGB(255, 46, 100, 66),
  300: Color.fromARGB(255, 46, 100, 66),
  400: Color.fromARGB(255, 46, 100, 66),
  500: Color.fromARGB(255, 46, 100, 66),
  600: Color.fromARGB(255, 46, 100, 66),
  700: Color.fromARGB(255, 46, 100, 66),
  800: Color.fromARGB(255, 46, 100, 66),
  900: Color.fromARGB(255, 46, 100, 66),
};

class Palette {
  static Color get primary =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 46, 100, 66)
          : const Color.fromARGB(255, 46, 100, 66);
  static Color get primaryOp =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(155, 46, 100, 66)
          : const Color.fromARGB(155, 46, 100, 66);
  static Color get cardFaq =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(100, 25, 203, 23)
          : const Color.fromARGB(100, 25, 203, 23);
          
  static Color get lightGrey =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 210, 210, 210)
          : const Color.fromARGB(255, 210, 210, 210);
  static Color get disabledButton =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(150, 46, 100, 66)
          : const Color.fromARGB(150, 46, 100, 66);

  static Color get iconsColor =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 46, 100, 66)
          : const Color.fromARGB(255, 46, 100, 66);
  static Color get backgroundLogin =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 150, 175, 161)
          : const Color.fromARGB(255, 150, 175, 161);

  static Color get secundary =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 181, 121, 69)
          : const Color.fromARGB(255, 181, 121, 69);
  static Color get lightGreen =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(150, 207, 214, 210)
          : const Color.fromARGB(150, 207, 214, 210);
  static Color get white =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? Colors.white
          : Colors.white;

  static Color get background =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? Colors.black
          : Colors.white;
  static Color get deselected =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? const Color.fromARGB(255, 215, 215, 215)
          : const Color.fromARGB(255, 215, 215, 215);
}

MaterialColor primaryColor = const MaterialColor(0xFFFFCF44, primarySwatch);
const int primaryColorDark = 0xFFFD9725;
