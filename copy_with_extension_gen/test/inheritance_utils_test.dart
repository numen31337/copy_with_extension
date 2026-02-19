import 'package:analyzer/dart/element/element.dart' show FieldElement;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/inheritance.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen_test/source_gen_test.dart'
    show initializeLibraryReaderForDirectory;
import 'package:test/test.dart';

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

void main() {
  final settings = Settings(
    copyWithNull: false,
    skipFields: false,
    immutableFields: false,
  );

  group('findAnnotatedSuper', () {
    test('resolves aliased superclass and keeps type arguments', () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'inheritance_utils_test.dart',
      );
      final childType = reader.findType('InheritanceAliasChild');
      expect(childType, isNotNull);
      final child = childType!;

      final superInfo = findAnnotatedSuper(child, settings);
      expect(superInfo, isNotNull);
      expect(superInfo!.name, 'InheritanceParent');
      expect(superInfo.element.displayName, 'InheritanceParent');
      expect(superInfo.typeArgumentsAnnotation(), '<int>');
    });
  });

  group('hasNonSkippedFieldProxy', () {
    test('walks alias chain and respects skipped annotated ancestors',
        () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'inheritance_utils_test.dart',
      );
      final middleType = reader.findType('InheritanceIntermediate');
      expect(middleType, isNotNull);
      final middle = middleType!;
      final localField = middle.getField('local');

      final result = hasNonSkippedFieldProxy(localField, settings);
      expect(result, isFalse);
    });

    test('walks alias chain and finds non-skipped annotated ancestors',
        () async {
      final reader = await initializeLibraryReaderForDirectory(
        'test',
        'inheritance_utils_test.dart',
      );
      final middleType = reader.findType('InheritanceIntermediateNonSkip');
      expect(middleType, isNotNull);
      final middle = middleType!;
      final localField = middle.getField('local');

      final result = hasNonSkippedFieldProxy(localField, settings);
      expect(result, isTrue);
    });

    test('returns false for null field', () {
      final FieldElement? field = null;
      expect(hasNonSkippedFieldProxy(field, settings), isFalse);
    });
  });
}
