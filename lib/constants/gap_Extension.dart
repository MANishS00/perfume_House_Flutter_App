import 'package:flutter/widgets.dart';

extension GapExtension on num {
  SizedBox get gap => SizedBox(height: toDouble());
  SizedBox get gapW => SizedBox(width: toDouble());
}
