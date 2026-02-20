import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement;

/// Utilities for resolving fields across a class inheritance hierarchy.
class ClassFieldLookup {
  const ClassFieldLookup._();

  /// Returns [fieldName] from [classElement] or its supertypes.
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
