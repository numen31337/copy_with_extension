import 'package:meta/meta.dart' show immutable, required;
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'subclass_test_case.g.dart';

abstract class AClass {
  final String? aString;

  AClass(this.aString);
}

@immutable
@CopyWith()
class BasicBaseClass {
  final String id;

  BasicBaseClass({this.id = 'test'});
}

mixin TestMixin on BasicBaseClass {
  String get mixinMethod;
}

@immutable
@CopyWith()
class BasicBaseSubClass<T> extends BasicBaseClass {
  @override
  final String id;
  final T? item;

  BasicBaseSubClass({required this.id, this.item});
}

@immutable
@CopyWith(generateCopyWithNull: true)
class SubClass<T, U extends String> extends BasicBaseSubClass<T>
    with TestMixin
    implements AClass {
  final DateTime date;
  @override
  final String? aString;
  @CopyWithField(immutable: true)
  final String? privateField;
  static String staticStr = 'test';
  final List<T>? listWithGenericType;
  final List<Iterable<U>?>? listWithTypedType;
  final List<int>? listWithType;
  @override
  final T? item;

  SubClass({
    required String id,
    required this.date,
    this.privateField,
    this.aString,
    this.listWithGenericType,
    this.listWithTypedType,
    this.listWithType,
    this.item,
  }) : super(id: id);

  SubClass.secondConstructor({required String id})
      : this(id: id, date: DateTime.now(), privateField: '', aString: '');

  factory SubClass.testFactory() {
    return SubClass.secondConstructor(id: '');
  }

  String get testMethod {
    return 'test';
  }

  @override
  String get mixinMethod {
    return 'test';
  }
}
