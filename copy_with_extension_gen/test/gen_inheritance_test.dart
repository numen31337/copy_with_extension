import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show test, expect;

part 'gen_inheritance_test.g.dart';

abstract class AbstractClass {
  AbstractClass(this.abstractString);

  final String? abstractString;
}

@CopyWith()
class BasicBaseClass {
  const BasicBaseClass({this.id = 'test'});

  final String id;
}

mixin Mixin on BasicBaseClass {
  String get mixinMethod;
}

@CopyWith()
class BasicSubClass<T> extends BasicBaseClass {
  const BasicSubClass({required super.id, this.item});

  final T? item;
}

@CopyWith()
class ComplexSubClass<T, U extends String> extends BasicSubClass<T>
    with Mixin
    implements AbstractClass {
  ComplexSubClass({
    required super.id,
    required this.date,
    this.privateField,
    this.abstractString,
    this.listWithGenericType,
    this.listWithTypedType,
    this.listWithType,
    super.item,
  });

  ComplexSubClass.secondConstructor({required String id})
      : this(
          id: id,
          date: DateTime.now(),
          privateField: '',
          abstractString: '',
        );

  factory ComplexSubClass.testFactory() {
    return ComplexSubClass.secondConstructor(id: '');
  }

  final DateTime date;
  @override
  final String? abstractString;
  @CopyWithField(immutable: true)
  final String? privateField;
  static String staticStr = 'test';
  final List<T>? listWithGenericType;
  final List<Iterable<U>?>? listWithTypedType;
  final List<int>? listWithType;

  String get testMethod {
    return 'test';
  }

  @override
  String get mixinMethod {
    return 'test';
  }
}

void main() {
  test('BasicSubClass', () {
    final result = const BasicSubClass<bool>(id: 'test')
        .copyWith
        .id("test1")
        .copyWith
        .item(true);

    expect(result.id, "test1");
    expect(result.item, true);
    expect(result.copyWith.item(null).item, null);
  });

  test('ComplexSubClass', () {
    final date = DateTime.now();
    final result = ComplexSubClass<int, String>(
      id: "testid",
      date: date,
      listWithTypedType: const [],
    ).copyWith();

    expect(
      result.copyWith().runtimeType,
      ComplexSubClass<int, String>(id: "", date: date).runtimeType,
    );

    expect(
      result.copyWith.id("").runtimeType,
      ComplexSubClass<int, String>(id: "", date: date).runtimeType,
    );

    expect(
      result.copyWith.runtimeType,
      _$ComplexSubClassCWProxyImpl<int, String>(
        ComplexSubClass<int, String>(id: "", date: date),
      ).runtimeType,
    );

    expect(
      result.listWithTypedType.runtimeType,
      <Iterable<String>?>[].runtimeType,
    );

    expect(
      result.copyWith.listWithGenericType([]).listWithGenericType.runtimeType,
      <int>[].runtimeType,
    );

    expect(
      result.copyWith.listWithTypedType([]).listWithTypedType.runtimeType,
      <Iterable<String>?>[].runtimeType,
    );

    final Mixin mixin = result;
    expect(
      mixin.mixinMethod,
      "test",
    );

    expect(result.abstractString, null);
    expect(result.copyWith.abstractString("test").abstractString, "test");
  });
}
