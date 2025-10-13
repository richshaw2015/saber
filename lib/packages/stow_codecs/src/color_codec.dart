import 'dart:ui' show Color;

import 'package:saber/packages/stow_codecs/stow_codecs.dart';

/// Encodes a [Color] as an ARGB32 integer.
class ColorCodec extends AbstractCodec<Color, int> {
  const ColorCodec();

  @override
  int encode(Color input) => input.value;

  @override
  Color decode(int encoded) => Color(encoded);
}
