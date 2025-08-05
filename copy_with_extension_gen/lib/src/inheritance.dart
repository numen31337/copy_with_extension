import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, Element2, FieldElement2, LibraryElement2;
import 'package:analyzer/dart/element/type.dart' show DartType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:source_gen/source_gen.dart' show ConstantReader, TypeChecker;

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
    required this.prefix,
    required this.typeArguments,
    required this.element,
    required this.skipFields,
    required this.copyWithNull,
    required this.constructor,
    required this.originLibrary,
  });

  /// The simple name of the superclass.
  final String name;

  /// Import prefix used to reference the superclass, if any.
  final String prefix;

  /// Raw type arguments provided to the superclass.
  final List<DartType> typeArguments;

  /// The element for the superclass, used for field lookups.
  final ClassElement2 element;

  /// Whether the superclass suppressed field-specific methods using
  /// `skipFields: true`.
  final bool skipFields;

  /// Whether the superclass enables `copyWithNull` generation.
  final bool copyWithNull;

  /// Named constructor used by the superclass, if any.
  final String? constructor;

  /// Library in which the subclass is defined. Needed to resolve import
  /// prefixes when rendering [typeArguments].
  final LibraryElement2 originLibrary;

  /// Returns the type arguments as they appear in source, e.g. `<T, U>`.
  String typeArgumentsAnnotation() {
    if (typeArguments.isEmpty) return '';
    final names = typeArguments
        .map((e) => ElementUtils.typeNameWithPrefix(originLibrary, e))
        .join(',');
    return '<$names>';
  }
}

/// Walks the inheritance chain of [classElement] and returns information
/// about the first superclass annotated with `@CopyWith`.
///
/// Returns `null` when no annotated superclass is found.
AnnotatedCopyWithSuper? findAnnotatedSuper(ClassElement2 classElement) {
  const checker = TypeChecker.fromRuntime(CopyWith);
  final library = classElement.library2;
  var supertype = classElement.supertype;
  while (supertype != null) {
    final element = supertype.element3;
    if (element is ClassElement2 && checker.hasAnnotationOf(element)) {
      final name = ElementUtils.readElementNameOrThrow(element as Element2);
      final prefix =
          ElementUtils.libraryImportPrefix(library, element.library2);
      final annotation = checker.firstAnnotationOf(element);
      final annotationReader =
          annotation == null ? null : ConstantReader(annotation);
      final skipFields =
          annotationReader?.peek('skipFields')?.boolValue ?? false;
      final copyWithNull =
          annotationReader?.peek('copyWithNull')?.boolValue ?? false;
      final constructor = annotationReader?.peek('constructor')?.stringValue;
      return AnnotatedCopyWithSuper(
        name: name,
        prefix: prefix,
        typeArguments: supertype.typeArguments,
        element: element,
        skipFields: skipFields,
        copyWithNull: copyWithNull,
        constructor: constructor,
        originLibrary: library,
      );
    }
    supertype = supertype.superclass;
  }
  return null;
}

/// Returns `true` when [field] originates from a class annotated with
/// `@CopyWith` where `skipFields` is `false`.
///
/// The check walks up the inheritance chain starting from the field's
/// declaring class and returns `false` if no such ancestor is found.
bool hasNonSkippedFieldProxy(FieldElement2? field) {
  if (field == null) return false;
  const checker = TypeChecker.fromRuntime(CopyWith);
  var current = field.enclosingElement2 as ClassElement2?;
  while (current != null) {
    if (checker.hasAnnotationOf(current)) {
      final annotation = checker.firstAnnotationOf(current);
      final skipFields =
          ConstantReader(annotation).peek('skipFields')?.boolValue ?? false;
      return !skipFields;
    }
    current = current.supertype?.element3 as ClassElement2?;
  }
  return false;
}
