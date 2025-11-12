import 'package:flutter_test/flutter_test.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

void main() {
  group('CarbonIcons lookup', () {
    test('fromName returns IconData for valid icon names', () {
      expect(CarbonIcons.fromName('account'), isNotNull);
      expect(CarbonIcons.fromName('add'), isNotNull);
    });

    test('fromName returns null for invalid icon names', () {
      expect(CarbonIcons.fromName('nonexistent_icon'), isNull);
    });

    test('byName map provides direct access', () {
      expect(CarbonIcons.byName['account'], isNotNull);
      expect(CarbonIcons.byName['add'], isNotNull);
    });

    test('original names with special characters work', () {
      expect(CarbonIcons.fromName('3D_Cursor'), isNotNull);
      expect(CarbonIcons.fromName('4K'), isNotNull);
    });

    test('direct static access still works', () {
      expect(CarbonIcons.account, isNotNull);
      expect(CarbonIcons.add, isNotNull);
    });

    test('fromName and direct access return same instance', () {
      expect(CarbonIcons.fromName('account'), equals(CarbonIcons.account));
      expect(CarbonIcons.byName['add'], equals(CarbonIcons.add));
    });
  });
}
