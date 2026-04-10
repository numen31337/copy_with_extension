import 'package:copy_with_extension_gen/src/resolved_copy_with_spec.dart';

import 'copy_with_values_template.dart';

/// Generates the proxy classes that power the `copyWith` API.
/// The proxy exposes both a `call` method and individual field setters.
String copyWithProxyTemplate(ResolvedCopyWithSpec spec) {
  // Generate proxy methods for each mutable field. These methods allow
  // modification of a single field via `instance.copyWith.fieldName(value)`.
  // Inherited fields delegate to the superclass implementation to avoid
  // duplicating logic.
  final nonNullableFunctions = spec.proxyMethodFields
      .map((field) {
        final shouldDelegate = field.delegatesToSuper;
        final body =
            shouldDelegate
                ? 'super.${field.name}(${field.name}) as ${spec.typeAnnotation}'
                : 'call(${field.name}: ${field.name})';
        final annotations =
            field.metadata.isEmpty ? '' : '${field.metadata.join(' ')} ';
        return '''
    @override
    ${spec.typeAnnotation} ${field.name}($annotations${field.type} ${field.name}) => $body;
    ''';
      })
      .join('\n');

  // Interface used by the proxy class. It mirrors the proxy methods above.
  final nonNullableFunctionsInterface = spec.proxyMethodFields
      .map((field) {
        final annotations =
            field.metadata.isEmpty ? '' : '${field.metadata.join(' ')} ';
        return '''
    ${field.delegatesToSuper ? '@override\n    ' : ''}${spec.typeAnnotation} ${field.name}($annotations${field.type} ${field.name});
    ''';
      })
      .join('\n');

  return '''
      abstract class _\$${spec.className}CWProxy${spec.typeParametersAnnotation}${spec.proxyExtendsClause} {
        $nonNullableFunctionsInterface

        ${copyWithValuesTemplate(spec, isAbstract: true, addOverride: spec.shouldExtendSuperProxy)};
      }

      /// Callable proxy for `copyWith` functionality.
      /// Use as `instanceOf${spec.className}.copyWith(...)`${spec.skipFields ? '' : ' or call `instanceOf${spec.className}.copyWith.fieldName(value)` for a single field'}.
      class _\$${spec.className}CWProxyImpl${spec.typeParametersAnnotation}${spec.proxyImplExtendsClause} implements _\$${spec.className}CWProxy${spec.typeParametersNames} {
        const _\$${spec.className}CWProxyImpl(${spec.shouldExtendSuperProxy ? '${spec.typeAnnotation} super._value' : 'this._value'});

        ${spec.shouldExtendSuperProxy ? '@override\n        ${spec.typeAnnotation} get _value => super._value as ${spec.typeAnnotation};' : 'final ${spec.typeAnnotation} _value;'}

        $nonNullableFunctions

        @override
        ${copyWithValuesTemplate(spec, isAbstract: false)}
      }
    ''';
}
