import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2, LibraryElement2;
import 'package:analyzer/dart/element/type.dart' show ParameterizedType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/helpers.dart';
import 'package:source_gen/source_gen.dart' show TypeChecker;

/*
 * Proxy inheritance is implemented by having each generated proxy extend
 * the proxy of the nearest superclass annotated with `@CopyWith`.
 *
 * This file encapsulates the lookup of that superclass. By keeping the
 * search logic self‑contained, the generator and templates can remain
 * focused on code emission and are free to swap out or refine the
 * strategy in the future.
 */

/// Details about a superclass annotated with `@CopyWith`.
///
/// This object bundles the information necessary for proxy inheritance
/// so the generator and templates don't need to parse the type structure
/// themselves.
class AnnotatedCopyWithSuper {
  const AnnotatedCopyWithSuper({
    required this.name,
    required this.typeParametersAnnotation,
    required this.typeParametersNames,
    required this.element,
  });

  /// The simple name of the superclass.
  final String name;

  /// Type arguments as they appear in source, e.g. `<T, U>`.
  final String typeParametersAnnotation;

  /// The same type arguments but used for proxy interfaces.
  ///
  /// Since `ParameterizedType` does not expose bounds, these two strings
  /// are currently identical. Keeping both allows the implementation to
  /// change independently in the future.
  final String typeParametersNames;

  /// The element for the superclass, used for field lookups.
  final ClassElement2 element;
}

/// Walks the inheritance chain of [classElement] and returns information
/// about the first superclass annotated with `@CopyWith`.
///
/// Returns `null` when no annotated superclass is found.
AnnotatedCopyWithSuper? findAnnotatedSuper(ClassElement2 classElement) {
  const checker = TypeChecker.fromRuntime(CopyWith);
  final library = classElement.library2;
  for (final supertype in classElement.allSupertypes) {
    final element = supertype.element3;
    if (element is ClassElement2 && checker.hasAnnotationOf(element)) {
      final name = readElementNameOrThrow(element as Element2);
      final generics = _typeArguments(library, supertype);
      return AnnotatedCopyWithSuper(
        name: name,
        typeParametersAnnotation: generics,
        typeParametersNames: generics,
        element: element,
      );
    }
  }
  return null;
}

/// Extracts the raw type arguments of [type] as `<T, U>` or returns an
/// empty string when the type is not generic.
String _typeArguments(LibraryElement2 library, ParameterizedType type) {
  final args = type.typeArguments;
  if (args.isEmpty) return '';
  final names = args.map((e) {
    final name = typeNameWithPrefix(library, e);
    return name.endsWith('?') ? name.substring(0, name.length - 1) : name;
  }).join(',');
  return '<$names>';
}
