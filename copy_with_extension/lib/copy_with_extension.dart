/// Provides `CopyWith` annotation class used by [copy_with_extension_gen](https://pub.dev/packages/copy_with_extension_gen).
library;

import 'package:meta/meta_meta.dart';

/// Generates a `copyWith` extension for a class or direct record typedef.
///
/// Annotation parameters configure only the declaration they are written on and are
/// never inherited from an annotated superclass. Inherited fields are still
/// included in the generated `copyWith`.
@Target({TargetKind.classType, TargetKind.typedefType})
class CopyWith {
  const CopyWith({
    this.copyWithNull,
    this.skipFields,
    this.constructor,
    this.immutableFields,
  });

  /// Set `copyWithNull` to `true` if you want to use `copyWithNull` function that allows you to nullify the fields. E.g. `myInstance.copyWithNull(id: true, name: true)`. Enable it on every subclass that needs it. Default is `false`.
  final bool? copyWithNull;

  /// Prevent the library from generating `copyWith` functions for individual fields e.g. `instance.copyWith.id("123")`, including inherited fields. If you want to use only copyWith(...) function. Default is `false`.
  final bool? skipFields;

  /// Selects a named class constructor. Records do not support this option.
  /// If not set, the unnamed class constructor is used.
  final String? constructor;

  /// Treats all fields as immutable by default when set to `true`.
  /// Class fields can still opt out using `@CopyWithField(immutable: false)`.
  /// Record components do not support field annotations.
  /// Defaults to `false`.
  final bool? immutableFields;
}

/// Field related options for the class's `CopyWith` annotation.
@Target({TargetKind.field})
class CopyWithField {
  const CopyWithField({this.immutable});

  /// Indicates that the field should be hidden in the generated `copyWith` and
  /// `copyWithNull` methods. By setting this flag to `true` the field will
  /// always be copied as it is and excluded from the generated interfaces.
  /// Default is `false`.
  final bool? immutable;
}

/// Placeholder used as the default value for parameters in generated methods.
/// It lets the generator distinguish between an explicitly passed `null` and
/// an omitted parameter, ensuring both nullable and non-nullable fields keep
/// their existing values when not updated.
class $CopyWithPlaceholder {
  const $CopyWithPlaceholder();
}
