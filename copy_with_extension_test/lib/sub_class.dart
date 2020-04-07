import 'package:meta/meta.dart' show immutable, required;
import 'package:copy_with_extension/copy_with_extension.dart';

part 'sub_class.g.dart';

abstract class AClass {
  final String aString;

  AClass(this.aString);
}

@immutable
@CopyWith()
class BasicBaseClass {
  final String id;

  BasicBaseClass({this.id});
}

mixin TestMixin on BasicBaseClass {
  String get mixinMethod;
}

@immutable
@CopyWith()
class SubClass<T, U extends String> extends BasicBaseClass
    with TestMixin
    implements AClass {
  final DateTime date;
  final String aString;
  final String privateField;
  static String staticStr;
  final List<T> listWithGenericType;
  final List<Iterable<U>> listWithTypedType;
  final List<int> listWithType;

  SubClass({
    String id,
    @required this.date,
    this.privateField,
    this.aString,
    this.listWithGenericType,
    this.listWithTypedType,
    this.listWithType,
  }) : super(id: id);

  SubClass.secondConstructor({String id})
      : this(id: id, date: DateTime.now(), privateField: "", aString: "");

  factory SubClass.testFactory() {
    return SubClass.secondConstructor(id: "");
  }

  String get testMethod {
    return "test";
  }

  String get mixinMethod {
    return "test";
  }
}
