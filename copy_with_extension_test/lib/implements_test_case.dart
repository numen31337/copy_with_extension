import 'package:meta/meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'implements_test_case.g.dart';

abstract class Abstract {
  final String aString;
  Abstract(this.aString);
}

abstract class AbstractWithType<T> {
  final T aString;
  AbstractWithType(this.aString);
}

@immutable
@CopyWith()
class Basic implements Abstract {
  Basic({this.aString});

  @override
  final String aString;
}

@immutable
@CopyWith()
class WithGenericType<T> implements AbstractWithType<T> {
  WithGenericType({this.aString});

  @override
  final T aString;
}

@immutable
@CopyWith()
class WithSpecificType implements AbstractWithType<String> {
  WithSpecificType({this.aString});

  @override
  final String aString;
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
