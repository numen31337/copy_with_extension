// ignore_for_file: unused_element, unused_element_parameter

import 'package:copy_with_extension/copy_with_extension.dart';

/// Make sure the `part` directive is specified before running the builder.
/// part 'example.g.dart'; // Do not comment this line.

/// Allows you to use it like this: `SimpleObject(id: "test").copyWith(id: "new values", intValue: 10).copyWithNull(intValue: true)`.
/// Or like this: `SimpleObject(id: "test").copyWith.id("new value")`.
@CopyWith(copyWithNull: true)
class SimpleObjectOldStyle {
  const SimpleObjectOldStyle({required this.id, this.intValue});

  final String id;
  final int? intValue;
}

/// Prevents modification of the `id` field after object creation. The value is always copied from the original instance.
@CopyWith()
class SimpleObjectImmutableField {
  const SimpleObjectImmutableField({this.id, this.intValue});

  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;
}

/// Allows the use of a private constructor.
@CopyWith(constructor: "_")
class SimpleObjectPrivateConstructor {
  const SimpleObjectPrivateConstructor._({this.id, this.intValue});

  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;
}
