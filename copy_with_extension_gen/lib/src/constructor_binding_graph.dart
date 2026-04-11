// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/analysis/results.dart' show ResolvedLibraryResult;
import 'package:analyzer/dart/ast/ast.dart'
    show
        BinaryExpression,
        ConstructorDeclaration,
        ConstructorFieldInitializer,
        Expression,
        NamedExpression,
        ParenthesizedExpression,
        SimpleIdentifier,
        SuperConstructorInvocation;
import 'package:analyzer/dart/ast/visitor.dart' show RecursiveAstVisitor;
import 'package:analyzer/dart/element/element.dart'
    show ConstructorElement, FormalParameterElement;
import 'package:build/build.dart' show log;

/// Explicit constructor parameter bindings derived from initializer semantics.
///
/// Each edge records whether a constructor parameter participates in an
/// alias-safe assignment or in a derived expression, and whether the target is a
/// local field or a super-constructor parameter.
class ConstructorBindingGraph {
  ConstructorBindingGraph._(this._bindingsBySource, {required this.isResolved});

  final Map<String, List<ConstructorBinding>> _bindingsBySource;

  /// Whether the graph was built from a resolved constructor AST.
  final bool isResolved;

  /// Whether any binding forwards through a super-constructor parameter.
  bool get hasSuperBindings {
    for (final bindings in _bindingsBySource.values) {
      if (bindings.any(
        (binding) =>
            binding.canResolveFieldAlias &&
            binding.isSuperConstructorForwarding,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Builds the binding graph for [constructor] from its resolved AST.
  static Future<ConstructorBindingGraph> build(
    ConstructorElement constructor,
  ) async {
    if (constructor.isFactory) {
      // Factory bodies and redirects do not expose generative initializer
      // bindings. Fall back to the legacy same-name field resolution path.
      return ConstructorBindingGraph._(
        const <String, List<ConstructorBinding>>{},
        isResolved: false,
      );
    }

    final library = constructor.library;
    final session = library.session;

    ResolvedLibraryResult? resolved;
    Exception? resolutionException;
    try {
      final result = await session.getResolvedLibraryByElement(library);
      if (result is ResolvedLibraryResult) {
        resolved = result;
      }
    } on Exception catch (exception) {
      resolutionException = exception;
    }
    if (resolved == null) {
      final reason =
          resolutionException == null
              ? ''
              : ' Analysis fallback triggered: $resolutionException';
      log.warning(
        'copy_with_extension_gen: Unable to resolve library for '
        '${constructor.enclosingElement.displayName}; constructor binding '
        'analysis will be limited.$reason',
      );
      return ConstructorBindingGraph._(
        const <String, List<ConstructorBinding>>{},
        isResolved: false,
      );
    }

    final declaration = resolved.getFragmentDeclaration(
      constructor.firstFragment,
    );
    final node = declaration?.node;
    if (node is! ConstructorDeclaration) {
      log.warning(
        'copy_with_extension_gen: Unable to resolve constructor node for '
        '${constructor.enclosingElement.displayName}.${constructor.displayName}; '
        'constructor binding analysis will be limited.',
      );
      return ConstructorBindingGraph._(
        const <String, List<ConstructorBinding>>{},
        isResolved: false,
      );
    }

    return _ConstructorBindingGraphBuilder(constructor).build(node);
  }

  /// Returns every binding whose source is [sourceParameter].
  Iterable<ConstructorBinding> bindingsForSource(String sourceParameter) {
    return _bindingsBySource[sourceParameter] ?? const <ConstructorBinding>[];
  }

  /// Whether the graph contains any binding evidence for [sourceParameter].
  bool hasBindingsForSource(String sourceParameter) {
    return _bindingsBySource.containsKey(sourceParameter);
  }

  /// Whether all known bindings for [sourceParameter] target only the same
  /// local field name.
  bool hasOnlySameNameFieldBindingsForSource(String sourceParameter) {
    final bindings = _bindingsBySource[sourceParameter];
    if (bindings == null || bindings.isEmpty) {
      return false;
    }

    return bindings.every((binding) {
      final target = binding.target;
      if (target is! FieldBindingTarget || target.name != sourceParameter) {
        return false;
      }
      return binding.canResolveFieldAlias;
    });
  }

  /// Returns field targets reached by alias-safe assignment from
  /// [sourceParameter].
  Iterable<String> fieldTargetsForSource(String sourceParameter) {
    final seen = <String>{};
    final targets = <String>[];
    for (final binding in bindingsForSource(sourceParameter)) {
      final target = binding.target;
      if (target is! FieldBindingTarget) {
        continue;
      }
      if (binding.canResolveFieldAlias && seen.add(target.name)) {
        targets.add(target.name);
      }
    }
    return targets;
  }

  /// Returns super-constructor parameter targets reached by alias-safe
  /// assignment from [sourceParameter].
  Iterable<String> superTargetsForSource(String sourceParameter) {
    final seen = <String>{};
    final targets = <String>[];
    for (final binding in bindingsForSource(sourceParameter)) {
      if (!binding.canResolveFieldAlias) {
        continue;
      }
      final target = binding.target;
      if (target is SuperParameterBindingTarget && seen.add(target.name)) {
        targets.add(target.name);
      }
    }
    return targets;
  }
}

/// A binding edge from a constructor parameter to a target.
class ConstructorBinding {
  const ConstructorBinding({
    required this.sourceParameter,
    required this.target,
    required this.computation,
  });

  final String sourceParameter;
  final ConstructorBindingTarget target;
  final ConstructorBindingComputation computation;

  bool get isDirectAssignment =>
      computation == ConstructorBindingComputation.directAssignment;

  bool get isDerivedExpression =>
      computation == ConstructorBindingComputation.derivedExpression;

  bool get isDefaultedAssignment =>
      computation == ConstructorBindingComputation.defaultedAssignment;

  bool get canResolveFieldAlias => isDirectAssignment || isDefaultedAssignment;

  bool get isSuperConstructorForwarding =>
      target is SuperParameterBindingTarget;
}

/// How a target value is computed from the source constructor parameter.
enum ConstructorBindingComputation {
  /// The target receives the source parameter value unchanged.
  directAssignment,

  /// The target receives the source parameter value when present, otherwise a
  /// default that does not depend on another constructor parameter.
  defaultedAssignment,

  /// The target is computed by an arbitrary expression and must not be treated
  /// as a field alias.
  derivedExpression,
}

/// Base type for graph targets.
sealed class ConstructorBindingTarget {
  const ConstructorBindingTarget(this.name);

  final String name;
}

/// Binding target for a field initializer.
final class FieldBindingTarget extends ConstructorBindingTarget {
  const FieldBindingTarget(super.name);
}

/// Binding target for a super-constructor parameter.
final class SuperParameterBindingTarget extends ConstructorBindingTarget {
  const SuperParameterBindingTarget(super.name);
}

class _ConstructorBindingGraphBuilder {
  _ConstructorBindingGraphBuilder(this._constructor)
    : _parameterNamesByElement = {
        for (final parameter in _constructor.formalParameters)
          parameter.baseElement: parameter.displayName,
      },
      _bindingsBySource = <String, List<ConstructorBinding>>{};

  final ConstructorElement _constructor;
  final Map<FormalParameterElement, String> _parameterNamesByElement;
  final Map<String, List<ConstructorBinding>> _bindingsBySource;

  ConstructorBindingGraph build(ConstructorDeclaration node) {
    _recordFormalParameterBindings();

    final expressionAnalyzer = _BindingExpressionAnalyzer(
      _parameterNamesByElement,
    );

    for (final initializer in node.initializers) {
      if (initializer is ConstructorFieldInitializer) {
        _recordBindings(
          expressionAnalyzer,
          target: FieldBindingTarget(initializer.fieldName.name),
          expression: initializer.expression,
        );
      } else if (initializer is SuperConstructorInvocation) {
        _recordSuperBindings(expressionAnalyzer, initializer);
      }
    }

    return ConstructorBindingGraph._(
      Map<String, List<ConstructorBinding>>.unmodifiable(
        _bindingsBySource.map(
          (key, value) =>
              MapEntry(key, List<ConstructorBinding>.unmodifiable(value)),
        ),
      ),
      isResolved: true,
    );
  }

  void _recordFormalParameterBindings() {
    for (final parameter in _constructor.formalParameters) {
      final sourceParameter = parameter.displayName;
      if (parameter.isInitializingFormal) {
        _bindingsBySource
            .putIfAbsent(sourceParameter, () => <ConstructorBinding>[])
            .add(
              ConstructorBinding(
                sourceParameter: sourceParameter,
                target: FieldBindingTarget(sourceParameter),
                computation: ConstructorBindingComputation.directAssignment,
              ),
            );
      }
      if (parameter.isSuperFormal) {
        _bindingsBySource
            .putIfAbsent(sourceParameter, () => <ConstructorBinding>[])
            .add(
              ConstructorBinding(
                sourceParameter: sourceParameter,
                target: SuperParameterBindingTarget(sourceParameter),
                computation: ConstructorBindingComputation.directAssignment,
              ),
            );
      }
    }
  }

  void _recordSuperBindings(
    _BindingExpressionAnalyzer expressionAnalyzer,
    SuperConstructorInvocation initializer,
  ) {
    var positionalIndex = 0;
    final superParameters =
        _constructor.superConstructor?.formalParameters ?? const [];

    for (final argument in initializer.argumentList.arguments) {
      if (argument is NamedExpression) {
        _recordBindings(
          expressionAnalyzer,
          target: SuperParameterBindingTarget(argument.name.label.name),
          expression: argument.expression,
        );
        continue;
      }

      if (positionalIndex >= superParameters.length) {
        continue;
      }

      final superParameter = superParameters[positionalIndex];
      _recordBindings(
        expressionAnalyzer,
        target: SuperParameterBindingTarget(superParameter.displayName),
        expression: argument,
      );
      positionalIndex++;
    }
  }

  void _recordBindings(
    _BindingExpressionAnalyzer expressionAnalyzer, {
    required ConstructorBindingTarget target,
    required Expression expression,
  }) {
    final analysis = expressionAnalyzer.analyze(expression);
    for (final sourceParameter in analysis.referencedParameters) {
      _bindingsBySource
          .putIfAbsent(sourceParameter, () => <ConstructorBinding>[])
          .add(
            ConstructorBinding(
              sourceParameter: sourceParameter,
              target: target,
              computation: analysis.computation,
            ),
          );
    }
  }
}

class _BindingExpressionAnalyzer {
  const _BindingExpressionAnalyzer(this._parameterNamesByElement);

  final Map<FormalParameterElement, String> _parameterNamesByElement;

  _BindingExpressionAnalysis analyze(Expression expression) {
    final collector = _ParameterReferenceCollector(_parameterNamesByElement);
    expression.accept(collector);

    return _BindingExpressionAnalysis(
      referencedParameters: collector.referencedParameters,
      computation:
          _isDirectParameterReference(expression)
              ? ConstructorBindingComputation.directAssignment
              : _isDefaultedAssignment(expression)
              ? ConstructorBindingComputation.defaultedAssignment
              : ConstructorBindingComputation.derivedExpression,
    );
  }

  bool _isDirectParameterReference(Expression expression) {
    return _parameterNameForDirectReference(expression) != null;
  }

  bool _isDefaultedAssignment(Expression expression) {
    final unwrapped = _unwrapParentheses(expression);
    if (unwrapped is! BinaryExpression || unwrapped.operator.lexeme != '??') {
      return false;
    }

    if (_parameterNameForDirectReference(unwrapped.leftOperand) == null) {
      return false;
    }

    final rightCollector = _ParameterReferenceCollector(
      _parameterNamesByElement,
    );
    unwrapped.rightOperand.accept(rightCollector);
    return rightCollector.referencedParameters.isEmpty;
  }

  String? _parameterNameForDirectReference(Expression expression) {
    final unwrapped = _unwrapParentheses(expression);
    if (unwrapped is! SimpleIdentifier || unwrapped.inDeclarationContext()) {
      return null;
    }

    final element = unwrapped.element;
    if (element is! FormalParameterElement) {
      return null;
    }

    return _parameterNamesByElement[element.baseElement];
  }

  Expression _unwrapParentheses(Expression expression) {
    var current = expression;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current;
  }
}

class _BindingExpressionAnalysis {
  const _BindingExpressionAnalysis({
    required this.referencedParameters,
    required this.computation,
  });

  final Set<String> referencedParameters;
  final ConstructorBindingComputation computation;
}

class _ParameterReferenceCollector extends RecursiveAstVisitor<void> {
  _ParameterReferenceCollector(this._parameterNamesByElement);

  final Map<FormalParameterElement, String> _parameterNamesByElement;
  final Set<String> referencedParameters = <String>{};

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.inDeclarationContext()) {
      return;
    }

    final element = node.element;
    if (element is FormalParameterElement) {
      final parameterName = _parameterNamesByElement[element.baseElement];
      if (parameterName != null) {
        referencedParameters.add(parameterName);
      }
    }

    super.visitSimpleIdentifier(node);
  }
}
