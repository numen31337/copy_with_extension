import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_field_annotation.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_basic_functionality_test.g.dart';

@CopyWith()
class CopyWithValues {
  const CopyWithValues({
    required this.id,
  });

  final String id;
}

@CopyWith(copyWithNull: true)
class CopyWithValuesOptional {
  const CopyWithValuesOptional({this.id});

  final String? id;
}

@CopyWith()
class CopyWithProxy {
  const CopyWithProxy({
    this.id,
    this.immutable,
  });

  final String? id;
  @CopyWithField(immutable: true)
  final String? immutable;
}

@CopyWith()
class CopyWithProxyChaining {
  const CopyWithProxyChaining({
    this.id,
    this.field,
  });

  final String? id;
  final String? field;
}

void main() {
  test('Default Settings Values', () {
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

  test('CopyWithValues', () {
    expect(
      const CopyWithValues(id: '').copyWith(id: "test").id,
      "test",
    );

    expect(const CopyWithValues(id: '').copyWith(id: null).id, '');
  });

  test('CopyWithValuesOptional', () {
    expect(
      const CopyWithValuesOptional().copyWith(id: "test").id,
      "test",
    );

    expect(
      const CopyWithValuesOptional(id: "test").copyWithNull(id: true).id,
      null,
    );

    expect(
      const CopyWithValuesOptional(id: "test").copyWith.id(null).id,
      null,
    );

    expect(
      const CopyWithValuesOptional(id: "test").copyWith(id: null).id,
      null,
    );
  });

  test('CopyWithProxy', () {
    expect(
      const CopyWithProxy().copyWith.id("test").id,
      "test",
    );

    expect(
      const CopyWithProxy(id: "test").copyWith.id(null).id,
      null,
    );
  });

  test('CopyWithProxyChaining', () {
    final result = const CopyWithProxyChaining()
        .copyWith
        .id("test")
        .copyWith
        .field("testField");

    expect(result.id, "test");
    expect(result.field, "testField");
  });
}
