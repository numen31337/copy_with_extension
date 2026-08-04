import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

import 'copy_with_values_template.dart';

/// Returns the shared method signature for a single proxy field setter.
String _proxyMethodSignature(
  ResolvedCopyWithField field,
  String typeAnnotation,
) =>
    '$typeAnnotation ${field.name}(${field.annotationPrefix}${field.type} ${field.name})';

/// Generates the proxy classes that power the `copyWith` API.
/// The proxy exposes both a `call` method and individual field setters.
String copyWithProxyTemplate(ResolvedCopyWithSpec spec) {
  // Generate proxy methods for each mutable field. These methods allow
  // modification of a single field via `instance.copyWith.fieldName(value)`.
  final nonNullableFunctions = spec.proxyMethodFields
      .map((field) {
        return '''
    @override
    ${_proxyMethodSignature(field, spec.typeAnnotation)} => call(${field.name}: ${field.name});
    ''';
      })
      .join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface = spec.proxyMethodFields
      .map((field) {
        return '''
    ${_proxyMethodSignature(field, spec.typeAnnotation)};
    ''';
      })
      .join('\n');

  return '''
      abstract class ${spec.proxyInterfaceName} {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(spec, isAbstract: true)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf${spec.className}.copyWith(...)`${spec.skipFields ? '' : ' or call `instanceOf${spec.className}.copyWith.fieldName(value)` for a single field'}.
      class ${spec.proxyImplName} implements ${spec.proxyInterfaceRef} {
        const ${spec.proxyImplBaseName}(this._value);

        final ${spec.typeAnnotation} _value;

        $nonNullableFunctions

        ${copyWithValuesTemplate(spec, isAbstract: false)}
      }
    ''';
}
