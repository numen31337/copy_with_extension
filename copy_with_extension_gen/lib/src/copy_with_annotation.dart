import 'package:copy_with_extension/copy_with_extension.dart';

/// The internal representation of parameters entered by the library's user.
class CopyWithAnnotation implements CopyWith {
  const CopyWithAnnotation({
    required this.constructor,
    required this.copyWithNull,
    required this.skipFields,
    required this.immutableFields,
    required this.allowNullForNonNullableFields,
  });

  @override
  final String? constructor;

  @override
  final bool copyWithNull;

  @override
  final bool skipFields;

  @override
  final bool immutableFields;

  @override
  final bool allowNullForNonNullableFields;
}
