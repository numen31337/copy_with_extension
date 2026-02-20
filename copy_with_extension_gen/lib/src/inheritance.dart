import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement, LibraryElement;
import 'package:analyzer/dart/element/type.dart' show DartType, InterfaceType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/element_utils.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
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
    required this.immutableFields,
    required this.originLibrary,
  });

  /// The simple name of the superclass.
  final String name;

  /// Import prefix used to reference the superclass, if any.
  final String prefix;

  /// Raw type arguments provided to the superclass.
  final List<DartType> typeArguments;

  /// The element for the superclass, used for field lookups.
  final ClassElement element;

  /// Whether the superclass suppressed field-specific methods using
  /// `skipFields: true`.
  final bool skipFields;

  /// Whether the superclass enables `copyWithNull` generation.
  final bool copyWithNull;

  /// Named constructor used by the superclass, if any.
  final String? constructor;

  /// Whether fields are immutable by default in the superclass.
  final bool immutableFields;

  /// Library in which the subclass is defined. Needed to resolve import
  /// prefixes when rendering [typeArguments].
  final LibraryElement originLibrary;

  /// Returns the type arguments as they appear in source, e.g. `<T, U>`.
  String typeArgumentsAnnotation() {
    final expectedArity = element.typeParameters.length;
    if (expectedArity == 0 || typeArguments.isEmpty) return '';
    if (typeArguments.length < expectedArity) return '';
    final normalizedTypeArguments = typeArguments.length == expectedArity
        ? typeArguments
        : typeArguments.take(expectedArity).toList(growable: false);
    final names = normalizedTypeArguments
        .map((e) => ElementUtils.typeNameWithPrefix(originLibrary, e))
        .join(', ');
    return '<$names>';
  }
}

/// Walks the inheritance chain of [classElement] and returns information
/// about the first superclass annotated with `@CopyWith`.
///
/// Returns `null` when no annotated superclass is found.
AnnotatedCopyWithSuper? findAnnotatedSuper(
  ClassElement classElement,
  Settings settings,
) {
  const checker = TypeChecker.typeNamed(CopyWith);
  final library = classElement.library;
  var supertype = classElement.supertype;
  while (supertype != null) {
    var element = supertype.element;
    final alias = supertype.alias;
    if (alias != null) {
      final aliased = alias.element.aliasedType.element;
      if (aliased is ClassElement) {
        element = aliased;
      }
    }
    if (element is ClassElement && checker.hasAnnotationOf(element)) {
      final name = element.displayName;
      final prefix = ElementUtils.libraryImportPrefix(library, element.library);
      final annotation = checker.firstAnnotationOf(element);
      if (annotation == null) {
        supertype = supertype.superclass;
        continue;
      }
      final classAnnotation = AnnotationUtils.readClassAnnotation(
        settings,
        ConstantReader(annotation),
      );
      return AnnotatedCopyWithSuper(
        name: name,
        prefix: prefix,
        typeArguments: _resolveSuperTypeArguments(supertype, element),
        element: element,
        skipFields: classAnnotation.skipFields,
        copyWithNull: classAnnotation.copyWithNull,
        constructor: classAnnotation.constructor,
        immutableFields: classAnnotation.immutableFields,
        originLibrary: library,
      );
    }
    supertype = supertype.superclass;
  }
  return null;
}

List<DartType> _resolveSuperTypeArguments(
  InterfaceType supertype,
  ClassElement superElement,
) {
  final expectedArity = superElement.typeParameters.length;
  if (expectedArity == 0) return const <DartType>[];

  final asInstance = supertype.asInstanceOf(superElement)?.typeArguments;
  if (asInstance != null && asInstance.length == expectedArity) {
    return asInstance;
  }

  final direct = supertype.typeArguments;
  if (direct.length == expectedArity) {
    return direct;
  }

  final alias = supertype.alias?.typeArguments;
  if (alias != null && alias.length == expectedArity) {
    return alias;
  }

  // Defensive fallback: some analyzer paths can expose alias-shape type
  // arguments here. Truncate extras to keep generated proxy inheritance valid.
  if (direct.length > expectedArity) {
    return direct.take(expectedArity).toList(growable: false);
  }
  if (asInstance != null && asInstance.length > expectedArity) {
    return asInstance.take(expectedArity).toList(growable: false);
  }
  if (alias != null && alias.length > expectedArity) {
    return alias.take(expectedArity).toList(growable: false);
  }

  return const <DartType>[];
}

/// Returns `true` when [field] originates from a class annotated with
/// `@CopyWith` where `skipFields` is `false`.
///
/// The check walks up the inheritance chain starting from the field's
/// declaring class and returns `false` if no such ancestor is found.
bool hasNonSkippedFieldProxy(FieldElement? field, Settings settings) {
  if (field == null) return false;
  const checker = TypeChecker.typeNamed(CopyWith);
  var current = field.enclosingElement as ClassElement?;
  while (current != null) {
    if (checker.hasAnnotationOf(current)) {
      final annotation = checker.firstAnnotationOf(current);
      if (annotation == null) return !settings.skipFields;
      final classAnnotation = AnnotationUtils.readClassAnnotation(
        settings,
        ConstantReader(annotation),
      );
      return !classAnnotation.skipFields;
    }
    final nextType = current.supertype;
    var next = nextType?.element;
    final alias = nextType?.alias;
    if (alias != null) {
      final aliased = alias.element.aliasedType.element;
      if (aliased is ClassElement) {
        next = aliased;
      }
    }
    current = next is ClassElement ? next : null;
  }
  return false;
}
