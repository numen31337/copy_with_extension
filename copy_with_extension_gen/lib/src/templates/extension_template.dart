import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';

import 'copy_with_null_template.dart';
import 'proxy_template.dart';

/// Builds the entire extension code snippet.
/// This method assembles the proxy class and the extension declaration that is added to the generated file.
String extensionTemplate({
  required bool isPrivate,
  required String className,
  required String typeParametersAnnotation,
  required String typeParametersNames,
  required List<ConstructorParameterInfo> fields,
  required bool skipFields,
  required bool copyWithNull,
  required String? constructor,
  required bool allowNullForNonNullableFields,
  AnnotatedCopyWithSuper? superInfo,
}) {
  final typeAnnotation = className + typeParametersNames;
  final privacyPrefix = isPrivate ? "_" : "";
  final proxy = copyWithProxyTemplate(
    constructor,
    className,
    typeParametersAnnotation,
    typeParametersNames,
    fields,
    skipFields,
    superInfo: superInfo,
    allowNullForNonNullableFields: allowNullForNonNullableFields,
  );
  final copyWithNullBlock = copyWithNull
      ? copyWithNullTemplate(typeAnnotation, fields, constructor, skipFields)
      : '';

  return '''
    $proxy

    extension $privacyPrefix\$${className}CopyWith$typeParametersAnnotation on $className$typeParametersNames {
      /// Returns a callable class used to build a new instance with modified fields.
      /// Example: `instanceOf$className.copyWith(...)`${skipFields ? "" : " or `instanceOf$className.copyWith.fieldName(...)`"}.
      // ignore: library_private_types_in_public_api
      _\$${className}CWProxy$typeParametersNames get copyWith => _\$${className}CWProxyImpl$typeParametersNames(this);

      $copyWithNullBlock
    }
    ''';
}
