import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

/// Make sure the `part` is specified before running the builder.
/// part 'example.g.dart'; /// It should not be commented.

/// Lets use it like this: `SimpleObject(id: "test").copyWith.id("new value")`.
@immutable
@CopyWith()
class SimpleObject {
  final String id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObject({required this.id, this.intValue});
}

/// Lets use it like this: `SimpleObject(id: "test").copyWithValues(id: "new values", intValue: 10).copyWithNull(intValue: true)`.
@immutable
@CopyWith(copyWith: false, copyWithNull: true, copyWithValues: true)
class SimpleObjectOldStyle {
  final String id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectOldStyle({required this.id, this.intValue});
}

/// Will not allow you to copy with modified `id` field after object creation.
@immutable
@CopyWith(copyWith: false, copyWithNull: true, copyWithValues: true)
class SimpleObjectImmutableField {
  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectImmutableField({this.id, this.intValue});
}

/// Allows the use of a private constructor.
@immutable
@CopyWith(namedConstructor: "_")
class SimpleObjectPrivateConstructor {
  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectPrivateConstructor._({this.id, this.intValue});
}
