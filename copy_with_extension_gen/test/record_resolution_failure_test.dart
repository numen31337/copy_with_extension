// ignore_for_file: experimental_member_use

import 'package:analyzer/dart/analysis/utilities.dart' show parseString;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:copy_with_extension_gen/src/copy_with_annotation.dart';
import 'package:copy_with_extension_gen/src/record_resolution_context.dart';
import 'package:source_gen/source_gen.dart' show InvalidGenerationSourceError;
import 'package:test/test.dart';

import 'helpers/source_gen_test_utils.dart';

void main() {
  late TypeAliasElement alias;
  const annotation = CopyWithAnnotation(
    constructor: null,
    copyWithNull: false,
    skipFields: false,
    immutableFields: false,
  );

  setUpAll(() async {
    final reader = await initializePackageLibraryReaderForDirectory(
      'test/fixtures',
      'record_resolution_input.dart',
    );
    alias = reader.element.typeAliases.single;
  });

  // Valid consumer source gives the resolver matching syntax and elements.
  // Inject unavailable or inconsistent syntax to check these defensive
  // diagnostics without malformed consumer code or generated-source assertions.
  test('reports unavailable alias syntax at the alias declaration', () async {
    await expectLater(
      RecordResolutionContext(alias, annotation, _BuildStep(null)).resolve(),
      throwsA(
        isA<InvalidGenerationSourceError>()
            .having(
              (error) => error.message,
              'message',
              'Cannot resolve the declaration syntax for record '
                  '"RecordResolutionInput".',
            )
            .having((error) => error.element, 'element', same(alias)),
      ),
    );
  });

  for (final (label, source, message) in [
    (
      'positional component count',
      'typedef RecordResolutionInput = ({String name});',
      'Cannot map positional record components without losing metadata.',
    ),
    (
      'named component count',
      'typedef RecordResolutionInput = (int,);',
      'Cannot map named record components without losing metadata.',
    ),
    (
      'named component identity',
      'typedef RecordResolutionInput = (int, {String other});',
      'Cannot map record component "name".',
    ),
  ]) {
    test('reports mismatched $label at the record syntax', () async {
      final declaration =
          parseString(
                content: source,
                path: resolvePackagePath(
                  'test/fixtures/record_resolution_input.dart',
                ),
              ).unit.declarations.single
              as GenericTypeAlias;

      await expectLater(
        RecordResolutionContext(
          alias,
          annotation,
          _BuildStep(declaration),
        ).resolve(),
        throwsA(
          isA<InvalidGenerationSourceError>()
              .having((error) => error.message, 'message', message)
              .having((error) => error.node, 'node', same(declaration.type)),
        ),
      );
    });
  }
}

class _BuildStep implements BuildStep {
  _BuildStep(AstNode? node) : resolver = _Resolver(node);

  @override
  final Resolver resolver;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Resolver implements Resolver {
  _Resolver(this.node);

  final AstNode? node;

  @override
  Future<AstNode?> astNodeFor(
    Fragment fragment, {
    bool resolve = false,
  }) async => node;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
