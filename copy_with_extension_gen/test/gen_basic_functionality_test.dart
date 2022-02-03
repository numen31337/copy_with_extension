import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_basic_functionality_test.g.dart';

@CopyWith()
class CopyWithValues {
  final String id;

  const CopyWithValues({
    required this.id,
  });
}

@CopyWith(copyWithNull: true)
class CopyWithValuesOptional {
  final String? id;

  const CopyWithValuesOptional({this.id});
}

@CopyWith()
class CopyWithProxy {
  final String? id;
  @CopyWithField(immutable: true)
  final String? immutable;

  const CopyWithProxy({
    this.id,
    this.immutable,
  });
}

@CopyWith()
class CopyWithProxyChaining {
  final String? id;
  final String? field;

  const CopyWithProxyChaining({
    this.id,
    this.field,
  });
}

void main() {
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
