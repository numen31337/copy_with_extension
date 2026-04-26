// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement;

/// Resolves fields across the full class type surface (superclasses, mixins,
/// and interfaces via [ClassElement.allSupertypes]).
///
/// This is intentionally broader than [InheritanceTraversal], which only
/// walks the direct superclass chain. Use this lookup for constructor
/// parameter resolution and metadata, where a field may originate from a
/// mixin or interface. Use [InheritanceTraversal] for proxy inheritance
/// decisions that must follow the `extends` chain only.
class ClassFieldLookup {
  const ClassFieldLookup._();

  /// Returns [fieldName] from [classElement] or any of its supertypes,
  /// including mixins and interfaces.
  static FieldElement? find(ClassElement classElement, String fieldName) {
    final ownField = classElement.getField(fieldName);
    if (ownField is FieldElement) return ownField;

    for (final supertype in classElement.allSupertypes) {
      final candidate = supertype.element.getField(fieldName);
      if (candidate is FieldElement) {
        return candidate;
      }
    }

    return null;
  }

  /// Returns `true` when [fieldName] exists in [classElement] or its supertypes.
  static bool exists(ClassElement classElement, String fieldName) {
    return find(classElement, fieldName) != null;
  }
}

/// Per-class cache for field resolution across the inheritance hierarchy.
///
/// Analyzer field walks can be repeated many times while resolving constructor
/// parameters, annotations, and generated proxy policy. Keeping one cache per
/// generation step ensures every caller observes the same resolved element.
class ClassFieldLookupCache {
  ClassFieldLookupCache(this._classElement);

  final ClassElement _classElement;
  final Map<String, FieldElement?> _fields = <String, FieldElement?>{};

  /// Returns [fieldName] from the cached class hierarchy lookup.
  FieldElement? find(String fieldName) {
    return _fields.putIfAbsent(
      fieldName,
      () => ClassFieldLookup.find(_classElement, fieldName),
    );
  }

  /// Returns `true` when [fieldName] exists in the cached class hierarchy.
  bool exists(String fieldName) {
    return find(fieldName) != null;
  }
}
