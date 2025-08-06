import 'package:analyzer/dart/ast/ast.dart'
    show
        ConstructorDeclaration,
        ConstructorFieldInitializer,
        Expression,
        NamedExpression,
        SimpleIdentifier,
        SuperConstructorInvocation;
import 'package:analyzer/dart/analysis/results.dart' show ParsedLibraryResult;
import 'package:analyzer/dart/ast/visitor.dart' show RecursiveAstVisitor;
import 'package:analyzer/dart/element/element2.dart'
    show ClassElement2, ConstructorElement2;

/// Resolves constructor parameters to the corresponding class fields.
///
/// This resolver handles parameters that are forwarded to fields with
/// different names as well as parameters forwarded to a super constructor.
class ConstructorFieldResolver {
  ConstructorFieldResolver(this._classElement, this._constructor)
      : _forwardMap = _buildForwardMap(_constructor);

  final ClassElement2 _classElement;
  final ConstructorElement2 _constructor;
  final Map<String, String> _forwardMap;

  /// Returns the field name for [paramName] or `null` if the field
  /// cannot be resolved on this class or any annotated superclasses.
  String? resolve(String paramName) {
    final forwarded = _forwardMap[paramName];
    final candidate = forwarded ?? paramName;
    if (_hasField(_classElement, candidate)) {
      return candidate;
    }
    if (forwarded == null) return null;
    final superConstructor = _constructor.superConstructor2;
    final superClass = _classElement.supertype?.element3 as ClassElement2?;
    if (superConstructor == null || superClass == null) {
      return null;
    }
    return ConstructorFieldResolver(superClass, superConstructor)
        .resolve(forwarded);
  }

  static Map<String, String> _buildForwardMap(ConstructorElement2 constructor) {
    final library = constructor.library2;
    final session = library.session;

    final parsed = session.getParsedLibraryByElement2(library);
    if (parsed is! ParsedLibraryResult) return const {};
    final declaration =
        parsed.getFragmentDeclaration(constructor.firstFragment);
    final node = declaration?.node;
    if (node is! ConstructorDeclaration) return const {};

    final parameterNames =
        constructor.formalParameters.map((p) => p.displayName).toSet();

    final result = <String, String>{};

    for (final initializer in node.initializers) {
      if (initializer is ConstructorFieldInitializer) {
        final fieldName = initializer.fieldName.name;
        final paramNames =
            _extractForwardedParameters(initializer.expression, parameterNames);
        for (final paramName in paramNames) {
          result[paramName] = fieldName;
        }
      } else if (initializer is SuperConstructorInvocation) {
        var positionalIndex = 0;
        final superParams =
            constructor.superConstructor2?.formalParameters ?? const [];
        for (final arg in initializer.argumentList.arguments) {
          if (arg is NamedExpression) {
            final paramNames =
                _extractForwardedParameters(arg.expression, parameterNames);
            for (final paramName in paramNames) {
              result[paramName] = arg.name.label.name;
            }
          } else {
            final paramNames = _extractForwardedParameters(arg, parameterNames);
            if (positionalIndex < superParams.length) {
              final superParam = superParams[positionalIndex];
              for (final paramName in paramNames) {
                result[paramName] = superParam.displayName;
              }
            }
            positionalIndex++;
          }
        }
      }
    }

    return result;
  }

  /// Returns the names of all parameters from [parameterNames] referenced
  /// within [expression].
  static Iterable<String> _extractForwardedParameters(
    Expression expression,
    Set<String> parameterNames,
  ) {
    final visitor = _ForwardedParameterVisitor(parameterNames);
    expression.accept(visitor);
    return visitor.names;
  }

  static bool _hasField(ClassElement2 element, String fieldName) {
    if (element.getField2(fieldName) != null) return true;
    for (final type in element.allSupertypes) {
      if (type.element3.getField2(fieldName) != null) {
        return true;
      }
    }
    return false;
  }
}

class _ForwardedParameterVisitor extends RecursiveAstVisitor<void> {
  _ForwardedParameterVisitor(this.candidates);

  final Set<String> candidates;
  final Set<String> names = {};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final name = node.name;
    if (candidates.contains(name)) {
      names.add(name);
    }
    super.visitSimpleIdentifier(node);
  }
}
