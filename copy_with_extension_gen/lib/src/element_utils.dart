// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart'
    show
        DartType,
        FunctionType,
        ParameterizedType,
        RecordType,
        TypeParameterType,
        NeverType;

/// Resolves named types in their surrounding function-type binder scope.
/// Built-in types such as `Never` have no declaration element.
typedef TypeReference =
    String Function(
      String name,
      Element? element,
      Set<String> localTypeParameters,
    );

/// Utilities for working with analyzer elements and types.
class ElementUtils {
  const ElementUtils._();

  /// Returns parameter names or full parameters declaration declared by this
  /// class or an empty string.
  ///
  /// If [nameOnly] is `true`: `class MyClass<T extends String, Y>` returns
  /// `<T, Y>`.
  ///
  /// If [nameOnly] is `false`: `class MyClass<T extends String, Y>` returns
  /// `<T extends String, Y>`.
  static String typeParametersString(
    TypeParameterizedElement classElement,
    bool nameOnly, {
    TypeReference? reference,
  }) {
    final names = classElement.typeParameters
        .map(
          (e) =>
              nameOnly
                  ? e.displayName
                  : _typeParameterWithPrefix(
                    classElement.library,
                    e,
                    reference,
                  ),
        )
        .join(', ');
    return names.isNotEmpty ? '<$names>' : '';
  }

  /// Recursively builds the display name for [type] including any import
  /// prefixes required to reference symbols from other libraries.
  static String typeNameWithPrefix(
    LibraryElement library,
    DartType type, {
    TypeReference? reference,
  }) {
    final nullability =
        type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

    final alias = type.alias;
    if (alias != null) {
      final aliasElement = alias.element;
      final aliasName =
          reference?.call(aliasElement.displayName, aliasElement, const {}) ??
          '${libraryImportPrefix(library, aliasElement.library)}${aliasElement.name}';
      if (alias.typeArguments.isNotEmpty) {
        final args = alias.typeArguments
            .map((t) => typeNameWithPrefix(library, t, reference: reference))
            .join(', ');
        return '$aliasName<$args>$nullability';
      }
      return '$aliasName$nullability';
    }

    if (type is FunctionType) {
      return '${_functionTypeNameWithPrefix(library, type, reference)}$nullability';
    }

    if (type is RecordType) {
      return '${_recordTypeNameWithPrefix(library, type, reference)}$nullability';
    }

    if (type is ParameterizedType) {
      final element = type.element;
      final name =
          element != null
              ? reference?.call(element.displayName, element, const {}) ??
                  '${libraryImportPrefix(library, element.library)}${element.name}'
              : displayStringWithoutNullability(type);

      if (type.typeArguments.isNotEmpty) {
        final args = type.typeArguments
            .map((t) => typeNameWithPrefix(library, t, reference: reference))
            .join(', ');
        return '$name<$args>$nullability';
      }
      return '$name$nullability';
    }

    final displayName = displayStringWithoutNullability(type);
    if (reference != null && (type is TypeParameterType || type is NeverType)) {
      return '${reference(displayName, type is NeverType ? null : type.element, const {})}$nullability';
    }
    return '${libraryImportPrefix(library, type.element?.library)}$displayName$nullability';
  }

  static String _functionTypeNameWithPrefix(
    LibraryElement library,
    FunctionType type,
    TypeReference? reference,
  ) {
    final outerReference = reference;
    if (outerReference != null) {
      reference =
          (name, element, innerParameters) => outerReference(name, element, {
            ...innerParameters,
            ...type.typeParameters.map((p) => p.displayName),
          });
    }
    final returnType = typeNameWithPrefix(
      library,
      type.returnType,
      reference: reference,
    );
    final typeParameters = type.typeParameters
        .map(
          (parameter) =>
              _typeParameterWithPrefix(library, parameter, reference),
        )
        .join(', ');
    final typeParametersSuffix =
        typeParameters.isNotEmpty ? '<$typeParameters>' : '';
    final parameters = _functionParametersWithPrefix(
      library,
      type.formalParameters,
      reference,
    );

    return '$returnType Function$typeParametersSuffix($parameters)';
  }

  static String _typeParameterWithPrefix(
    LibraryElement library,
    TypeParameterElement parameter,
    TypeReference? reference,
  ) {
    final bound = parameter.bound;
    if (bound == null) {
      return parameter.displayName;
    }
    return '${parameter.displayName} extends ${typeNameWithPrefix(library, bound, reference: reference)}';
  }

  static String _functionParametersWithPrefix(
    LibraryElement library,
    List<FormalParameterElement> parameters,
    TypeReference? reference,
  ) {
    final requiredPositional = <String>[];
    final optionalPositional = <String>[];
    final named = <String>[];

    for (final parameter in parameters) {
      final parameterType = typeNameWithPrefix(
        library,
        parameter.type,
        reference: reference,
      );
      if (parameter.isNamed) {
        final required = parameter.isRequiredNamed ? 'required ' : '';
        named.add('$required$parameterType ${parameter.displayName}');
      } else if (parameter.isOptionalPositional) {
        optionalPositional.add(parameterType);
      } else {
        requiredPositional.add(parameterType);
      }
    }

    final parameterSegments = <String>[];
    if (requiredPositional.isNotEmpty) {
      parameterSegments.add(requiredPositional.join(', '));
    }
    if (optionalPositional.isNotEmpty) {
      parameterSegments.add('[${optionalPositional.join(', ')}]');
    }
    if (named.isNotEmpty) {
      parameterSegments.add('{${named.join(', ')}}');
    }

    return parameterSegments.join(', ');
  }

  static String _recordTypeNameWithPrefix(
    LibraryElement library,
    RecordType type,
    TypeReference? reference,
  ) {
    final positional =
        type.positionalFields
            .map(
              (field) =>
                  typeNameWithPrefix(library, field.type, reference: reference),
            )
            .toList();
    final named =
        type.namedFields
            .map(
              (field) =>
                  '${typeNameWithPrefix(library, field.type, reference: reference)} ${field.name}',
            )
            .toList();

    final segments = <String>[];
    if (positional.isNotEmpty) {
      var positionalSignature = positional.join(', ');
      if (positional.length == 1 && named.isEmpty) {
        positionalSignature = '$positionalSignature,';
      }
      segments.add(positionalSignature);
    }
    if (named.isNotEmpty) {
      segments.add('{${named.join(', ')}}');
    }

    return '(${segments.join(', ')})';
  }

  /// Returns the import prefix for [targetLibrary] if one exists in [library].
  static String libraryImportPrefix(
    LibraryElement library,
    LibraryElement? targetLibrary,
  ) {
    if (targetLibrary == null) return '';
    final unit = library.fragments.first;
    for (final PrefixElement prefix in unit.prefixes) {
      for (final LibraryImport import in prefix.imports) {
        if (import.importedLibrary == targetLibrary) {
          final prefixName = prefix.name;
          if (prefixName is String && prefixName.isNotEmpty) {
            return '$prefixName.';
          }
        }
      }
    }
    return '';
  }

  /// Returns the `displayString` of [type] without a trailing question mark.
  static String displayStringWithoutNullability(DartType type) {
    final displayString = type.getDisplayString();
    return displayString.endsWith('?')
        ? displayString.substring(0, displayString.length - 1)
        : displayString;
  }
}
