import 'package:copy_with_extension_gen/src/constructor_parameter_info.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';

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
  required Settings settings,
}) {
  final typeAnnotation = type + typeParameterNames;
  final filteredFields =
      fields.where((e) => !e.fieldAnnotation.immutable).toList();
  final uniqueFilteredFields = uniqueConstructorFields(filteredFields);

  // When a superclass is also annotated with `@CopyWith`, the generated
  // proxy inherits from the parent's proxy interface as long as both classes
  // live in the same library. Proxies generated in a different library are
  // private and can't be referenced, so we skip inheritance in that case and
  // inline the required functionality instead.
  final shouldExtendSuper =
      superInfo != null && superInfo.element.library == superInfo.originLibrary;
  final extendsProxy = shouldExtendSuper
      ? ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxy${superInfo.typeArgumentsAnnotation()}'
      : '';
  final extendsImpl = shouldExtendSuper
      ? ' extends ${superInfo.prefix}_\$${superInfo.name}CWProxyImpl${superInfo.typeArgumentsAnnotation()}'
      : '';
  bool delegatesToSuper(ConstructorParameterInfo field) =>
      shouldExtendSuper &&
      field.isInherited &&
      hasNonSkippedFieldProxy(field.classField, settings);

  // Determine which fields require proxy methods. When [skipFields] is true,
  // only inherited fields need to be overridden to adjust the return type.
  final fieldsForProxyMethods = uniqueFilteredFields.where(
    (e) => !skipFields || delegatesToSuper(e),
  );

  // Generate proxy methods for each mutable field. These methods allow
  // modification of a single field via `instance.copyWith.fieldName(value)`.
  // Inherited fields delegate to the superclass implementation to avoid
  // duplicating logic.
  final nonNullableFunctions = fieldsForProxyMethods.map((e) {
    final shouldDelegate = delegatesToSuper(e);
    final body = shouldDelegate
        ? 'super.${e.name}(${e.name}) as $type$typeParameterNames'
        : 'call(${e.name}: ${e.name})';
    final annotations = e.metadata.isEmpty ? '' : '${e.metadata.join(' ')} ';
    return '''
    @override
    $type$typeParameterNames ${e.name}($annotations${e.type} ${e.name}) => $body;
    ''';
  }).join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface = fieldsForProxyMethods.map(
    (e) {
      final annotations = e.metadata.isEmpty ? '' : '${e.metadata.join(' ')} ';
      return '''
    ${delegatesToSuper(e) ? '@override\n    ' : ''}$type$typeParameterNames ${e.name}($annotations${e.type} ${e.name});
    ''';
    },
  ).join('\n');

  return '''
      abstract class _\$${type}CWProxy$typeParameters$extendsProxy {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(typeAnnotation, fields, uniqueFilteredFields, constructor, skipFields, true, addOverride: shouldExtendSuper)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf$type.copyWith(...)`${skipFields ? '' : ' or call `instanceOf$type.copyWith.fieldName(value)` for a single field'}.
      class _\$${type}CWProxyImpl$typeParameters$extendsImpl implements _\$${type}CWProxy$typeParameterNames {
        const _\$${type}CWProxyImpl(${shouldExtendSuper ? '$type$typeParameterNames super._value' : 'this._value'});

        ${shouldExtendSuper ? '@override\n        $type$typeParameterNames get _value => super._value as $type$typeParameterNames;' : 'final $type$typeParameterNames _value;'}

        $nonNullableFunctions

        @override
        ${copyWithValuesTemplate(typeAnnotation, fields, uniqueFilteredFields, constructor, skipFields, false)}
      }
    ''';
}
