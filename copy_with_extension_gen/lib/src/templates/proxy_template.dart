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
  // Inherited fields delegate to the superclass implementation to avoid
  // duplicating logic.
  final nonNullableFunctions = spec.proxyMethodFields
      .map((field) {
        final body =
            field.delegatesToSuper
                ? 'super.${field.name}(${field.name}) as ${spec.typeAnnotation}'
                : 'call(${field.name}: ${field.name})';
        return '''
    @override
    ${_proxyMethodSignature(field, spec.typeAnnotation)} => $body;
    ''';
      })
      .join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface = spec.proxyMethodFields
      .map((field) {
        final override = field.delegatesToSuper ? '@override\n    ' : '';
        return '''
    $override${_proxyMethodSignature(field, spec.typeAnnotation)};
    ''';
      })
      .join('\n');

  return '''
      abstract class ${spec.proxyInterfaceName}${spec.proxyExtendsClause} {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(spec, isAbstract: true, addOverride: spec.shouldExtendSuperProxy)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf${spec.className}.copyWith(...)`${spec.skipFields ? '' : ' or call `instanceOf${spec.className}.copyWith.fieldName(value)` for a single field'}.
      class ${spec.proxyImplName}${spec.proxyImplExtendsClause} implements ${spec.proxyInterfaceRef} {
        const ${spec.proxyImplBaseName}(${spec.shouldExtendSuperProxy ? '${spec.typeAnnotation} super._value' : 'this._value'});

        ${spec.shouldExtendSuperProxy ? '@override\n        ${spec.typeAnnotation} get _value => super._value as ${spec.typeAnnotation};' : 'final ${spec.typeAnnotation} _value;'}

        $nonNullableFunctions

        @override
        ${copyWithValuesTemplate(spec, isAbstract: false)}
      }
    ''';
}
