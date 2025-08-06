import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, LibraryElement2, LibraryImport, PrefixElement2;
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart'
    show DartType, ParameterizedType;

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
      ClassElement2 classElement, bool nameOnly) {
    final names = classElement.typeParameters2
        .map((e) => nameOnly ? e.displayName : e.displayString2())
        .join(',');
    return names.isNotEmpty ? '<$names>' : '';
  }

  /// Recursively builds the display name for [type] including any import
  /// prefixes required to reference symbols from other libraries.
  static String typeNameWithPrefix(LibraryElement2 library, DartType type) {
    final nullability =
        type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

    final alias = type.alias;
    if (alias != null) {
      final aliasElement = alias.element2;
      final aliasName =
          '${libraryImportPrefix(library, aliasElement.library2)}${aliasElement.name3}';
      if (alias.typeArguments.isNotEmpty) {
        final args = alias.typeArguments
            .map((t) => typeNameWithPrefix(library, t))
            .join(', ');
        return '$aliasName<$args>$nullability';
      }
      return '$aliasName$nullability';
    }

    if (type is ParameterizedType) {
      final element = type.element3;
      final name = element != null
          ? '${libraryImportPrefix(library, element.library2)}${element.name3}'
          : displayStringWithoutNullability(type);

      if (type.typeArguments.isNotEmpty) {
        final args = type.typeArguments
            .map((t) => typeNameWithPrefix(library, t))
            .join(', ');
        return '$name<$args>$nullability';
      }
      return '$name$nullability';
    }

    final displayName = displayStringWithoutNullability(type);
    return '${libraryImportPrefix(library, type.element3?.library2)}$displayName$nullability';
  }

  /// Returns the import prefix for [targetLibrary] if one exists in [library].
  static String libraryImportPrefix(
      LibraryElement2 library, LibraryElement2? targetLibrary) {
    if (targetLibrary == null) return '';
    final unit = library.fragments.first;
    for (final PrefixElement2 prefix in unit.prefixes) {
      for (final LibraryImport import in prefix.imports) {
        if (import.importedLibrary2 == targetLibrary) {
          final prefixName = prefix.name3;
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
