import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

part 'gen_inheritance_test.g.dart';

abstract class AbstractClass {
  final String? abstractString;

  AbstractClass(this.abstractString);
}

@immutable
@CopyWith()
class BasicBaseClass {
  final String id;

  const BasicBaseClass({this.id = 'test'});
}

mixin Mixin on BasicBaseClass {
  String get mixinMethod;
}

@immutable
@CopyWith()
class BasicSubClass<T> extends BasicBaseClass {
  final T? item;

  const BasicSubClass({required String id, this.item}) : super(id: id);
}

@immutable
@CopyWith()
class ComplexSubClass<T, U extends String> extends BasicSubClass<T>
    with Mixin
    implements AbstractClass {
  final DateTime date;
  @override
  final String? abstractString;
  @CopyWithField(immutable: true)
  final String? privateField;
  static String staticStr = 'test';
  final List<T>? listWithGenericType;
  final List<Iterable<U>?>? listWithTypedType;
  final List<int>? listWithType;

  ComplexSubClass({
    required String id,
    required this.date,
    this.privateField,
    this.abstractString,
    this.listWithGenericType,
    this.listWithTypedType,
    this.listWithType,
    T? item,
  }) : super(id: id, item: item);

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
    )._copyWithNull()._copyWithValues();

    expect(
      result._copyWithValues().runtimeType,
      ComplexSubClass<int, String>(id: "", date: date).runtimeType,
    );

    expect(
      result._copyWithNull().runtimeType,
      ComplexSubClass<int, String>(id: "", date: date).runtimeType,
    );

    expect(
      result.copyWith.id("").runtimeType,
      ComplexSubClass<int, String>(id: "", date: date).runtimeType,
    );

    expect(
      result.copyWith.runtimeType,
      _ComplexSubClassCopyWithProxy<int, String>(
        ComplexSubClass<int, String>(id: "", date: date),
      ).runtimeType,
    );

    expect(
      result.listWithTypedType.runtimeType,
      <Iterable<String>?>[].runtimeType,
    );

    // expect(
    //   result.copyWith.listWithGenericType([]),
    //   <Iterable<String>?>[].runtimeType,
    // );

    // final test_ok = result._copyWithValues();
    // //TODO: we are losing type here
    // final test = result.copyWith.id("");
    // final test2 = result.copyWith;

    expect(
      result.copyWith.listWithTypedType([]).listWithTypedType.runtimeType,
      <Iterable<String>?>[].runtimeType,
    );
  });
}
