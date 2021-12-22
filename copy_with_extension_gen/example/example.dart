import 'package:copy_with_extension/copy_with_extension.dart';

/// Make sure the `part` is specified before running the builder.
/// part 'example.g.dart'; /// It should not be commented.

/// Lets you use it like this: `SimpleObject(id: "test").copyWith(id: "new values", intValue: 10).copyWithNull(intValue: true)`.
/// Or like this: `SimpleObject(id: "test").copyWith.id("new value")`.
@CopyWith(copyWithNull: true)
class SimpleObjectOldStyle {
  final String id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectOldStyle({required this.id, this.intValue});
}

/// Won't allow you to copy this object with a modified `id` field after object creation. It will always copy it from the original instance.
@CopyWith()
class SimpleObjectImmutableField {
  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectImmutableField({this.id, this.intValue});
}

/// Allows the use of a private constructor.
@CopyWith(namedConstructor: "_")
class SimpleObjectPrivateConstructor {
  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObjectPrivateConstructor._({this.id, this.intValue});
}
