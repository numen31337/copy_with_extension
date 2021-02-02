import 'package:meta/meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'implements_test_case.g.dart';

abstract class Abstract {
  final String aField;
  Abstract(this.aField);
}

abstract class AbstractWithType<T> {
  final T tField;
  AbstractWithType(this.tField);
}

abstract class AbstractWithType1<T> {
  final T t1Field;
  AbstractWithType1(this.t1Field);
}

abstract class AbstractWithType2<T, Y> {
  final T saField;
  final Y sa1Field;
  AbstractWithType2(this.saField, this.sa1Field);
}

@immutable
@CopyWith()
class Basic implements Abstract {
  Basic({required this.aField});

  @override
  final String aField;
}

@immutable
@CopyWith()
class WithGenericType<T> implements AbstractWithType<T> {
  WithGenericType({required this.tField});

  @override
  final T tField;
}

@immutable
@CopyWith()
class WithSpecificType implements AbstractWithType<String> {
  WithSpecificType({required this.tField});

  @override
  final String tField;
}

@immutable
@CopyWith()
class WithBoth<T extends String, Y>
    implements
        Abstract,
        AbstractWithType<T>,
        AbstractWithType1<int>,
        AbstractWithType2<String, Y> {
  WithBoth({
    required this.aField,
    required this.tField,
    required this.t1Field,
    required this.saField,
    required this.sa1Field,
  });

  @override
  final String aField;
  @override
  final T tField;
  @override
  final int t1Field;
  @override
  final String saField;
  @override
  final Y sa1Field;
}
