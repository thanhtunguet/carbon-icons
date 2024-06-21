echo "converting SVG files to ttf"
fantasticon --config fantasticon_config.js

echo "generating IconData from ttf"
dart font_generator.dart

echo "formatting generated dart file"
dart format generated/carbon_fonts.dart

cp generated/carbon_fonts.dart ../lib/src/fonts/carbon_fonts.dart
cp -r generated/* ../docs
cp generated/CarbonFonts.ttf ../assets

mv ../docs/CarbonFonts.html ../docs/index.html

exec $SHELL;
