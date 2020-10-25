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
  Basic({this.aField});

  @override
  final String aField;
}

@immutable
@CopyWith()
class WithGenericType<T> implements AbstractWithType<T> {
  WithGenericType({this.tField});

  @override
  final T tField;
}

@immutable
@CopyWith()
class WithSpecificType implements AbstractWithType<String> {
  WithSpecificType({this.tField});

  @override
  final String tField;
}

@immutable
@CopyWith()
class WithBoth<T, Y>
    implements
        Abstract,
        AbstractWithType<T>,
        AbstractWithType1<int>,
        AbstractWithType2<String, Y> {
  WithBoth({
    this.aField,
    this.tField,
    this.t1Field,
    this.saField,
    this.sa1Field,
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

/// User's test case https://github.com/numen31337/copy_with_extension/issues/21
@immutable
@CopyWith()
class MediaContent implements Comparable<MediaContent> {
  final String id;
  final String media;
  final DateTime createdOn;
  final String type;

  MediaContent({
    @required this.media,
    @required this.type,
    this.id,
    this.createdOn,
  });

  @override
  int compareTo(MediaContent other) {
    throw UnimplementedError();
  }
}
