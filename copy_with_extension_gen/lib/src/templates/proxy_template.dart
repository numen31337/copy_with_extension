import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';

import 'copy_with_values_template.dart';
import 'field_utils.dart';

/// Generates the proxy classes that power the `copyWith` API.
/// The proxy exposes both a `call` method and individual field setters.
String copyWithProxyTemplate(
  String? constructor,
  String type,
  String typeParameters,
  String typeParameterNames,
  List<ConstructorParameterInfo> fields,
  bool skipFields, {
  AnnotatedCopyWithSuper? superInfo,
}) {
  final typeAnnotation = type + typeParameterNames;
  final filteredFields =
      fields.where((e) => !e.fieldAnnotation.immutable).toList();
  final uniqueFilteredFields = uniqueConstructorFields(filteredFields);

  // When a superclass is also annotated with `@CopyWith`, the generated
  // proxy inherits from the parent's proxy interface. This keeps the
  // subclass' proxy compatible with the superclass and allows chaining.
  final extendsProxy = superInfo == null
      ? ''
      : ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxy${superInfo.typeArgumentsAnnotation()}';
  final extendsImpl = superInfo == null
      ? ''
      : ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxyImpl${superInfo.typeArgumentsAnnotation()}';

  // Determine which fields require proxy methods. When [skipFields] is true,
  // only inherited fields need to be overridden to adjust the return type.
  final fieldsForProxyMethods = uniqueFilteredFields.where(
    (e) =>
        !skipFields ||
        (superInfo != null &&
            e.isInherited &&
            hasNonSkippedFieldProxy(e.classField)),
  );

  // Generate proxy methods for each mutable field. These methods allow
  // modification of a single field via `instance.copyWith.fieldName(value)`.
  // Inherited fields delegate to the superclass implementation to avoid
  // duplicating logic.
  final nonNullableFunctions = fieldsForProxyMethods.map((e) {
    final shouldDelegate = superInfo != null &&
        e.isInherited &&
        hasNonSkippedFieldProxy(e.classField);
    final body = shouldDelegate
        ? 'super.${e.name}(${e.name}) as $type$typeParameterNames'
        : 'call(${e.name}: ${e.name})';
    return '''
    @override
    $type$typeParameterNames ${e.name}(${e.type} ${e.name}) => $body;
    ''';
  }).join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface = fieldsForProxyMethods
      .map(
        (e) => '''
    ${superInfo != null && e.isInherited && hasNonSkippedFieldProxy(e.classField) ? '@override\n    ' : ''}$type$typeParameterNames ${e.name}(${e.type} ${e.name});
    ''',
      )
      .join('\n');

  return '''
      abstract class _\$${type}CWProxy$typeParameters$extendsProxy {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(typeAnnotation, fields, uniqueFilteredFields, constructor, skipFields, true, addOverride: superInfo != null)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf$type.copyWith(...)`${skipFields ? '' : ' or call `instanceOf$type.copyWith.fieldName(value)` for a single field'}.
      class _\$${type}CWProxyImpl$typeParameters$extendsImpl implements _\$${type}CWProxy$typeParameterNames {
        const _\$${type}CWProxyImpl(${superInfo != null ? '$type$typeParameterNames super._value' : 'this._value'});

        ${superInfo != null ? '@override\n        $type$typeParameterNames get _value => super._value as $type$typeParameterNames;' : 'final $type$typeParameterNames _value;'}

        $nonNullableFunctions

        @override
        ${copyWithValuesTemplate(typeAnnotation, fields, uniqueFilteredFields, constructor, skipFields, false)}
      }
    ''';
}
