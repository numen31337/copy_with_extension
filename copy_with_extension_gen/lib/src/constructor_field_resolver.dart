import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement;
import 'package:copy_with_extension_gen/src/class_field_lookup.dart';
import 'package:copy_with_extension_gen/src/constructor_binding_graph.dart';

/// Resolves constructor parameters to the corresponding class fields.
///
/// Resolution is driven by an explicit binding graph so direct assignment,
/// derived expressions, and super-constructor forwarding remain distinct.
class ConstructorFieldResolver {
  ConstructorFieldResolver._(
    this._classElement,
    this._bindingGraph, {
    required ClassFieldLookupCache fieldLookup,
    ConstructorFieldResolver? superResolver,
  }) : _fieldLookup = fieldLookup,
       _superResolver = superResolver;

  final ClassElement _classElement;
  final ConstructorBindingGraph _bindingGraph;
  final ClassFieldLookupCache _fieldLookup;
  final ConstructorFieldResolver? _superResolver;

  /// Creates a resolver for [constructor] and its super-constructor chain.
  static Future<ConstructorFieldResolver> create(
    ClassElement classElement,
    ConstructorElement constructor, {
    ClassFieldLookupCache? fieldLookup,
  }) async {
    final bindingGraph = await ConstructorBindingGraph.build(constructor);
    final superConstructor = constructor.superConstructor;
    final superClass = classElement.supertype?.element as ClassElement?;

    final superResolver =
        bindingGraph.hasSuperBindings &&
                superConstructor != null &&
                superClass != null
            ? await ConstructorFieldResolver.create(
              superClass,
              superConstructor,
            )
            : null;

    return ConstructorFieldResolver._(
      classElement,
      bindingGraph,
      fieldLookup: fieldLookup ?? ClassFieldLookupCache(classElement),
      superResolver: superResolver,
    );
  }

  /// Returns the field name for [paramName] or `null` if the field
  /// cannot be resolved on this class or any annotated superclasses.
  String? resolve(String paramName) {
    final hasSameNameField =
        _bindingGraph.isResolved
            ? _classElement.getField(paramName) != null
            : _fieldLookup.exists(paramName);
    final canUseSameNameField =
        (!_bindingGraph.isResolved &&
            !_bindingGraph.hasBindingsForSource(paramName)) ||
        _bindingGraph.hasOnlySameNameFieldBindingsForSource(paramName);
    if (hasSameNameField && canUseSameNameField) {
      return paramName;
    }

    final localField = _resolveLocalField(paramName);
    final superField = _resolveSuperField(paramName);

    if (localField != null && superField != null) {
      return null;
    }

    return localField ?? superField;
  }

  /// Whether binding analysis found constructor initializer evidence for
  /// [paramName].
  bool hasBindingEvidence(String paramName) {
    return _bindingGraph.hasBindingsForSource(paramName);
  }

  String? _resolveLocalField(String paramName) {
    String? resolvedField;

    for (final fieldName in _bindingGraph.fieldTargetsForSource(paramName)) {
      if (_classElement.getField(fieldName) == null) {
        continue;
      }
      if (resolvedField != null && resolvedField != fieldName) {
        return null;
      }
      resolvedField = fieldName;
    }

    return resolvedField;
  }

  String? _resolveSuperField(String paramName) {
    final superResolver = _superResolver;
    if (superResolver == null) {
      return null;
    }

    String? resolvedField;
    for (final superParameter in _bindingGraph.superTargetsForSource(
      paramName,
    )) {
      final candidate = superResolver.resolve(superParameter);
      if (candidate == null) {
        continue;
      }
      if (resolvedField != null && resolvedField != candidate) {
        return null;
      }
      resolvedField = candidate;
    }

    return resolvedField;
  }
}
