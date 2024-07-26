import 'dart:convert';
import 'dart:io';

const _codePointMapPath = 'generated/CarbonFonts.json';

const _generatedOutputFilePath = 'generated/carbon_fonts.dart';

const _ignoredKeywords = <String, String>{
  '1st': 'first_1st',
  '2nd': 'second_2nd',
  '3rd': 'third_3rd',
  '2d': 'two_d',
  '3d': 'three_d',
  '3g': 'three_g',
  '4g': 'four_g',
  '5g': 'five_g',
  '2k': 'two_k',
  '4k': 'four_k',
};
const _reservedWords = <String>[
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'with',
  'while'
];

const _template = """
// Generated code - do not modify!

import 'package:flutter/widgets.dart';

part 'package:supa_carbon_icons/src/widgets/icon_data.dart';

class CarbonIcons {
  CarbonIcons._();


""";

void main() {
  File codePointMapFile = File(_codePointMapPath);

  if (!codePointMapFile.existsSync()) {
    throw ("Could not find 'generated/CarbonFonts.json' file.");
  }

  final fileContent = codePointMapFile.readAsStringSync();
  Map<String, dynamic> codePointMap = json.decode(fileContent);

  final fontAppender = StringBuffer('');
  fontAppender.write(_template);
  codePointMap.forEach((fontName, codePoint) {
    fontAppender.write(_getFontData(codePoint, fontName));
  });
  fontAppender.write("}");

  File generatedOutput = File(_generatedOutputFilePath);
  generatedOutput.writeAsStringSync(fontAppender.toString());
}

String _getFontData(int codePoint, String fontName) {
  String iconName = fontName.toLowerCase();
  for (final entry in _ignoredKeywords.entries) {
    final key = entry.key;
    if (iconName.startsWith(key)) {
      iconName = fontName.toLowerCase().replaceFirst(key, entry.value);
      break;
    }
  }

  // Automatically append an underscore if the iconName is a reserved word
  if (_reservedWords.contains(iconName)) {
    iconName = "${iconName}_";
  }

  final radix16 = codePoint.toRadixString(16).toUpperCase();
  final iconDataItem =
      'static const IconData $iconName = _CarbonIconData(0x$radix16);\n';
  return iconDataItem;
}
