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
import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ConstructorElement;
import 'package:build/build.dart' show log;

/// Resolves constructor parameters to the corresponding class fields.
///
/// This resolver handles parameters that are forwarded to fields with
/// different names as well as parameters forwarded to a super constructor.
class ConstructorFieldResolver {
  ConstructorFieldResolver(this._classElement, this._constructor)
      : _forwardMap = _buildForwardMap(_constructor);

  final ClassElement _classElement;
  final ConstructorElement _constructor;
  final Map<String, String> _forwardMap;

  /// Returns the field name for [paramName] or `null` if the field
  /// cannot be resolved on this class or any annotated superclasses.
  String? resolve(String paramName) {
    if (_hasField(_classElement, paramName)) {
      return paramName;
    }
    final forwarded = _forwardMap[paramName];
    if (forwarded == null) {
      return null;
    }
    if (_hasField(_classElement, forwarded)) {
      return forwarded;
    }
    final superConstructor = _constructor.superConstructor;
    final superClass = _classElement.supertype?.element as ClassElement?;
    if (superConstructor == null || superClass == null) {
      return null;
    }
    return ConstructorFieldResolver(superClass, superConstructor)
        .resolve(forwarded);
  }

  static Map<String, String> _buildForwardMap(ConstructorElement constructor) {
    final library = constructor.library;
    final session = library.session;

    final parsed = session.getParsedLibraryByElement(library);
    if (parsed is! ParsedLibraryResult) {
      log.warning(
        'copy_with_extension_gen: Unable to parse library for '
        '${constructor.enclosingElement.displayName}; constructor field '
        'forwarding will be limited.',
      );
      return const {};
    }
    final declaration =
        parsed.getFragmentDeclaration(constructor.firstFragment);
    final node = declaration?.node;
    if (node is! ConstructorDeclaration) {
      log.warning(
        'copy_with_extension_gen: Unable to resolve constructor node for '
        '${constructor.enclosingElement.displayName}.${constructor.displayName}; '
        'constructor field forwarding will be limited.',
      );
      return const {};
    }

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
            constructor.superConstructor?.formalParameters ?? const [];
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

  static bool _hasField(ClassElement element, String fieldName) {
    if (element.getField(fieldName) != null) return true;
    for (final type in element.allSupertypes) {
      if (type.element.getField(fieldName) != null) {
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
