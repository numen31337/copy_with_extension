// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement, LibraryElement;
import 'package:analyzer/dart/element/type.dart' show DartType, InterfaceType;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/annotation_utils.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
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

const _copyWithChecker = TypeChecker.typeNamed(CopyWith);

/// One class reached while walking a class `extends` chain.
///
/// [element] is normalized so typedef aliases point at their underlying class,
/// while [type] preserves the original instantiated type used to reach it.
class InheritanceStep {
  const InheritanceStep({required this.type, required this.element});

  /// The instantiated type from the class hierarchy.
  final InterfaceType type;

  /// The class element represented by [type], with aliases unwrapped.
  final ClassElement element;
}

/// Normalized helpers for walking class inheritance.
///
/// These APIs deliberately follow only the superclass chain. Interfaces and
/// mixins are not generated proxy ancestors, so callers that make proxy
/// decisions should not inspect `allSupertypes` directly. This is intentionally
/// narrower than `ClassFieldLookup`, which resolves actual field elements
/// across the full interface surface for constructor and metadata handling.
class InheritanceTraversal {
  const InheritanceTraversal._();

  /// Returns [classElement] followed by each superclass in order.
  static List<InheritanceStep> selfAndAncestorsOf(ClassElement classElement) {
    return _walk(classElement.thisType);
  }

  /// Returns each superclass of [classElement] in order.
  static List<InheritanceStep> ancestorsOf(ClassElement classElement) {
    return _walk(classElement.supertype);
  }

  /// Returns the first field named [fieldName] in [classElement]'s superclass
  /// chain, optionally including [classElement] itself.
  static FieldElement? findField(
    ClassElement classElement,
    String fieldName, {
    bool includeSelf = true,
  }) {
    final steps =
        includeSelf
            ? selfAndAncestorsOf(classElement)
            : ancestorsOf(classElement);
    for (final step in steps) {
      final field = step.element.getField(fieldName);
      if (field is FieldElement) {
        return field;
      }
    }
    return null;
  }

  /// Returns `true` when [fieldName] is declared anywhere in the selected
  /// class chain.
  static bool declaresField(
    ClassElement classElement,
    String fieldName, {
    bool includeSelf = true,
  }) {
    return findField(classElement, fieldName, includeSelf: includeSelf) != null;
  }

  static List<InheritanceStep> _walk(InterfaceType? startType) {
    final steps = <InheritanceStep>[];
    final visited = <ClassElement>{};
    var currentType = startType;

    while (currentType != null) {
      final element = _normalizedClassElement(currentType);
      if (element == null || !visited.add(element)) {
        break;
      }

      steps.add(InheritanceStep(type: currentType, element: element));
      // Advance through the instantiated type so generic substitutions from
      // intermediate classes and aliases are preserved in later steps.
      currentType = currentType.superclass;
    }

    return steps;
  }

  static ClassElement? _normalizedClassElement(InterfaceType type) {
    final alias = type.alias;
    if (alias != null) {
      final aliased = alias.element.aliasedType.element;
      if (aliased is ClassElement) {
        return aliased;
      }
    }

    final element = type.element;
    return element is ClassElement ? element : null;
  }
}

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
    required this.annotation,
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

  /// The parsed `@CopyWith` annotation values declared on the superclass.
  final CopyWithAnnotation annotation;

  /// Library in which the subclass is defined. Needed to resolve import
  /// prefixes when rendering [typeArguments].
  final LibraryElement originLibrary;

  /// Returns the type arguments as they appear in source, e.g. `<T, U>`.
  String typeArgumentsAnnotation() {
    final expectedArity = element.typeParameters.length;
    if (expectedArity == 0 || typeArguments.isEmpty) return '';
    if (typeArguments.length < expectedArity) return '';
    final normalizedTypeArguments =
        typeArguments.length == expectedArity
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
  final library = classElement.library;
  for (final ancestor in InheritanceTraversal.ancestorsOf(classElement)) {
    final element = ancestor.element;
    if (_copyWithChecker.hasAnnotationOf(element)) {
      final name = element.displayName;
      final prefix = ElementUtils.libraryImportPrefix(library, element.library);
      final annotation = _copyWithChecker.firstAnnotationOf(element);
      if (annotation == null) {
        continue;
      }
      final classAnnotation = AnnotationUtils.readClassAnnotation(
        settings,
        ConstantReader(annotation),
      );
      return AnnotatedCopyWithSuper(
        name: name,
        prefix: prefix,
        typeArguments: _resolveSuperTypeArguments(ancestor.type, element),
        element: element,
        annotation: classAnnotation,
        originLibrary: library,
      );
    }
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

  final declaringClass = field.enclosingElement;
  if (declaringClass is! ClassElement) {
    return false;
  }

  for (final ancestor in InheritanceTraversal.selfAndAncestorsOf(
    declaringClass,
  )) {
    final element = ancestor.element;
    if (_copyWithChecker.hasAnnotationOf(element)) {
      final annotation = _copyWithChecker.firstAnnotationOf(element);
      if (annotation == null) return !settings.skipFields;
      final classAnnotation = AnnotationUtils.readClassAnnotation(
        settings,
        ConstantReader(annotation),
      );
      return !classAnnotation.skipFields;
    }
  }
  return false;
}
