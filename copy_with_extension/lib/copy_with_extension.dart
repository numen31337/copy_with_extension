/// Provides `CopyWith` annotation class used by [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library copy_with_extension;

import 'package:meta/meta_meta.dart';

/// Annotation used to indicate that the `copyWith` extension should be generated for the given class.
@Target({TargetKind.classType})
class CopyWith {
  const CopyWith({
    this.copyWithNull,
    this.skipFields,
    this.constructor,
  });

  /// Set `copyWithNull` to `true` if you want to use `copyWithNull` function that allows you to nullify the fields. E.g. `myInstance.copyWithNull(id: true, name: true)`. Default is `false`.
  final bool? copyWithNull;

  /// Prevent the library from generating `copyWith` functions for individual fields e.g. `instance.copyWith.id("123")`. If you want to use only copyWith(...) function. Default is `false`.
  final bool? skipFields;

  /// Set `constructor` if you want to use a named constructor. The generated fields will be derived from this constructor. If not set, the unnamed constructor is used.
  final String? constructor;
}

/// Field related options for the class's `CopyWith` annotation.
@Target({TargetKind.field})
class CopyWithField {
  const CopyWithField({this.immutable});

  /// Indicates that the field should be hidden in the generated `copyWith` method. By setting this flag to `true` the field will always be copied as it is and excluded from `copyWith` interface. Default is `false`.
  final bool? immutable;
}

/// This placeholder object is a default value for nullable fields to handle cases when the user wants to nullify the value.
class $CopyWithPlaceholder {
  const $CopyWithPlaceholder();
}
