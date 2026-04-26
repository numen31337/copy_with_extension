import 'package:analyzer/dart/element/element.dart'
    show ClassElement, FieldElement;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show LibraryReader;
import 'package:source_gen_test/source_gen_test.dart' show generateForElement;
import 'package:test/test.dart';

import 'helpers/source_gen_test_utils.dart';

@CopyWith()
class InheritanceParent<T> {
  const InheritanceParent(this.value);
  final T value;
}

typedef InheritanceParentAlias<T> = InheritanceParent<T>;

@CopyWith()
class InheritanceAliasChild extends InheritanceParentAlias<int> {
  const InheritanceAliasChild(super.value);
}

@CopyWith(skipFields: true)
class InheritanceSkipParent {
  const InheritanceSkipParent(this.value);
  final int value;
}

typedef InheritanceSkipParentAlias = InheritanceSkipParent;

class InheritanceIntermediate extends InheritanceSkipParentAlias {
  const InheritanceIntermediate(super.value, this.local);

  final int local;
}

@CopyWith()
class InheritanceNonSkipParent {
  const InheritanceNonSkipParent(this.value);
  final int value;
}

typedef InheritanceNonSkipAlias = InheritanceNonSkipParent;

class InheritanceIntermediateNonSkip extends InheritanceNonSkipAlias {
  const InheritanceIntermediateNonSkip(super.value, this.local);

  final int local;
}

@CopyWith()
class InheritanceProxyBase {
  const InheritanceProxyBase({required this.base});

  final int base;
}

class InheritanceProxyMiddle extends InheritanceProxyBase {
  const InheritanceProxyMiddle({required super.base, required this.middle});

  final int middle;
}

@CopyWith()
class InheritanceProxyChild extends InheritanceProxyMiddle {
  const InheritanceProxyChild({
    required super.base,
    required super.middle,
    required this.child,
  });

  final int child;
}

@CopyWith()
class InheritanceGenericBase<T> {
  const InheritanceGenericBase(this.generic);

  final T generic;
}

class InheritanceGenericMiddle<U> extends InheritanceGenericBase<List<U>> {
  const InheritanceGenericMiddle(super.generic);
}

typedef InheritanceGenericMiddleAlias<V> = InheritanceGenericMiddle<V>;

@CopyWith()
class InheritanceGenericLeaf extends InheritanceGenericMiddleAlias<int> {
  const InheritanceGenericLeaf(super.generic);
}

void main() {
  final settings = Settings(
    copyWithNull: false,
    skipFields: false,
    immutableFields: false,
  );
  late LibraryReader reader;

  setUpAll(() async {
    reader = await initializePackageLibraryReaderForDirectory(
      'test',
      'inheritance_utils_test.dart',
    );
  });

  ClassElement findClass(String name) {
    final type = reader.findType(name);
    expect(type, isNotNull);
    return type!;
  }

  group('InheritanceTraversal', () {
    test('walks aliases as normalized superclass elements', () {
      final child = findClass('InheritanceAliasChild');
      final ancestors = InheritanceTraversal.ancestorsOf(child);

      expect(ancestors, isNotEmpty);
      expect(ancestors.first.element.displayName, 'InheritanceParent');
      expect(
        ancestors.first.type.typeArguments.single.getDisplayString(),
        'int',
      );
    });

    test('findField can include or exclude the starting class', () {
      final middle = findClass('InheritanceIntermediate');
      expect(
        InheritanceTraversal.findField(middle, 'local')?.displayName,
        'local',
      );
      expect(
        InheritanceTraversal.findField(middle, 'local', includeSelf: false),
        isNull,
      );
      expect(
        InheritanceTraversal.findField(
          middle,
          'value',
          includeSelf: false,
        )?.displayName,
        'value',
      );
    });

    test('preserves generic substitutions through aliased intermediates', () {
      final leaf = findClass('InheritanceGenericLeaf');
      final ancestors = InheritanceTraversal.ancestorsOf(leaf);

      expect(ancestors[0].element.displayName, 'InheritanceGenericMiddle');
      expect(ancestors[0].type.typeArguments.single.getDisplayString(), 'int');
      expect(ancestors[1].element.displayName, 'InheritanceGenericBase');
      expect(
        ancestors[1].type.typeArguments.single.getDisplayString(),
        'List<int>',
      );
    });
  });

  group('findAnnotatedSuper', () {
    test('resolves aliased superclass and keeps type arguments', () {
      final child = findClass('InheritanceAliasChild');
      final superInfo = findAnnotatedSuper(child, settings);
      expect(superInfo, isNotNull);
      expect(superInfo!.name, 'InheritanceParent');
      expect(superInfo.element.displayName, 'InheritanceParent');
      expect(superInfo.typeArgumentsAnnotation(), '<int>');
    });

    test('keeps substituted type arguments past aliased intermediates', () {
      final leaf = findClass('InheritanceGenericLeaf');

      final superInfo = findAnnotatedSuper(leaf, settings);

      expect(superInfo, isNotNull);
      expect(superInfo!.name, 'InheritanceGenericBase');
      expect(superInfo.typeArgumentsAnnotation(), '<List<int>>');
    });
  });

  group('hasNonSkippedFieldProxy', () {
    test('walks alias chain and respects skipped annotated ancestors', () {
      final middle = findClass('InheritanceIntermediate');
      final localField = middle.getField('local');

      final result = hasNonSkippedFieldProxy(localField, settings);
      expect(result, isFalse);
    });

    test('walks alias chain and finds non-skipped annotated ancestors', () {
      final middle = findClass('InheritanceIntermediateNonSkip');
      final localField = middle.getField('local');

      final result = hasNonSkippedFieldProxy(localField, settings);
      expect(result, isTrue);
    });

    test('returns false for null field', () {
      final FieldElement? field = null;
      expect(hasNonSkippedFieldProxy(field, settings), isFalse);
    });
  });

  group('proxy delegation', () {
    test('does not delegate fields from unannotated intermediates', () async {
      final output = await generateForElement(
        CopyWithGenerator(settings),
        reader,
        'InheritanceProxyChild',
      );

      expect(output, contains('super.base(base) as InheritanceProxyChild'));
      expect(
        output,
        contains(
          'InheritanceProxyChild middle(int middle) => call(middle: middle);',
        ),
      );
      expect(output, isNot(contains('super.middle(middle)')));
    });
  });
}
