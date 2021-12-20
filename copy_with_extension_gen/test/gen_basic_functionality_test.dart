import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_basic_functionality_test.g.dart';

@CopyWith(copyWith: false, copyWithValues: true, copyWithNull: false)
class CopyWithValues {
  final String id;

  const CopyWithValues({
    required this.id,
  });
}

@CopyWith(copyWith: true, copyWithValues: true, copyWithNull: true)
class CopyWithValuesOptional {
  final String? id;

  const CopyWithValuesOptional({
    this.id,
  });
}

@CopyWith(copyWith: true, copyWithValues: false, copyWithNull: false)
class CopyWithProxy {
  final String? id;

  const CopyWithProxy({
    this.id,
  });
}

@CopyWith(copyWith: true, copyWithValues: false, copyWithNull: false)
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
      const CopyWithValues(id: '').copyWithValues(id: "test").id,
      "test",
    );
  });

  test('CopyWithValuesOptional', () {
    expect(
      const CopyWithValuesOptional().copyWithValues(id: "test").id,
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
