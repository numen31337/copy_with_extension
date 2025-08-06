import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/constructor_utils.dart';

/// Generates the body of the `call` method used by the proxy.
/// The returned snippet can be used either as an abstract interface (when [isAbstract] is `true`)
/// or as a concrete implementation that instantiates the target class.
String copyWithValuesTemplate(
  String typeAnnotation,
  List<ConstructorParameterInfo> allFields,
  List<ConstructorParameterInfo> uniqueFields,
  String? constructor,
  bool skipFields,
  bool isAbstract, {
  bool addOverride = false,
}) {
  // Build the parameter list for the generated function or abstract interface. Immutable fields are excluded entirely.
  final constructorInput = uniqueFields.fold<String>('', (r, v) {
    if (v.fieldAnnotation.immutable) return r;

    if (isAbstract) {
      // When generating the interface, parameters are typed directly.
      return '$r ${v.type} ${v.name},';
    } else {
      // The implementation uses [\$CopyWithPlaceholder] to detect whether a parameter was passed.
      return '$r Object? ${v.name} = const \$CopyWithPlaceholder(),';
    }
  });

  // Generate the parameters passed to the constructor when creating the new instance. Immutable fields are copied from the existing value.
  final paramsInput = allFields.fold<String>('', (r, v) {
    if (v.fieldAnnotation.immutable) {
      return v.isPositioned
          ? '$r _value.${v.name},'
          : '$r ${v.constructorParamName}: _value.${v.name},';
    }
    final placeholder = v.nullable
        ? '${v.name} == const \$CopyWithPlaceholder()'
        : '${v.name} == const \$CopyWithPlaceholder() || ${v.name} == null';

    return '''$r ${v.isPositioned ? '' : '${v.constructorParamName}:'}'''
        '''
        $placeholder
        ? _value.${v.name}
        // ignore: cast_nullable_to_non_nullable
        : ${v.name} as ${v.type},''';
  });

  final constructorBody = isAbstract
      ? ''
      : '{ return ${ConstructorUtils.constructorFor(typeAnnotation, constructor)}($paramsInput); }';

  return '''
        /// Creates a new instance with the provided field values.
        /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.${skipFields ? '' : ' To update a single field use `$typeAnnotation(...).copyWith.fieldName(value)`.'}
        ///
        /// Example:
        /// ```dart
        /// $typeAnnotation(...).copyWith(id: 12, name: "My name")
        /// ```
${addOverride ? '        @override\n' : ''}        $typeAnnotation call({$constructorInput}) $constructorBody
    ''';
}
