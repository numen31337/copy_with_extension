import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:test/test.dart';

void main() {
  group('Settings', () {
    test('Default values', () {
      final randomGlobalSettings = Settings.fromConfig(<String, dynamic>{
        'test1': 'test1',
        'test2': 123,
        'copyWithNull': 123,
        'skipFields': null,
      });
      final emptyGlobalSettings = Settings.fromConfig(<String, dynamic>{});
      const defaultFieldAnnotation = CopyWithFieldAnnotation.defaults();

      expect(randomGlobalSettings.copyWithNull, false);
      expect(randomGlobalSettings.skipFields, false);
      expect(emptyGlobalSettings.copyWithNull, false);
      expect(emptyGlobalSettings.skipFields, false);
      expect(defaultFieldAnnotation.immutable, false);
    });

    test('Custom values', () {
      final customSettings = Settings.fromConfig(<String, dynamic>{
        'copy_with_null': true,
        'skip_fields': true,
      });

      expect(customSettings.copyWithNull, true);
      expect(customSettings.skipFields, true);
    });
  });
}
