import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:copy_with_extension_gen/src/copy_with_generator.dart';
import 'package:copy_with_extension_gen/src/settings.dart';
import 'package:source_gen/source_gen.dart' show LibraryReader;
import 'package:source_gen_test/source_gen_test.dart' show generateForElement;
import 'package:test/test.dart';

import 'helpers/source_gen_test_utils.dart';

@CopyWith()
class CovariantParent {
  const CovariantParent({this.value = 0});

  final num value;
}

@CopyWith()
class CovariantChild extends CovariantParent {
  const CovariantChild({required this.value});

  @override
  // ignore: overridden_fields
  final int value;
}

@CopyWith(immutableFields: true)
class LockedParent {
  const LockedParent({required this.a});

  final int a;
}

@CopyWith()
class OpenChild extends LockedParent {
  const OpenChild({required super.a, required this.b});

  final int b;
}

@CopyWith()
class OpenParent {
  const OpenParent({required this.a});

  final int a;
}

@CopyWith(immutableFields: true)
class LockedChild extends OpenParent {
  const LockedChild({required super.a});
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
      'proxy_independence_test.dart',
    );
  });

  Future<String> generate(String className) =>
      generateForElement(CopyWithGenerator(settings), reader, className);

  group('independent proxy generation', () {
    test('proxies never extend another proxy or delegate via super', () async {
      for (final className in [
        'CovariantChild',
        'OpenChild',
        'LockedChild',
        'InheritanceProxyChild',
      ]) {
        final output = await generate(className);
        expect(output, isNot(contains('extends _\$')));
        expect(output, isNot(contains('super.')));
      }
    });

    test('covariant narrowed field generates a compilable proxy', () async {
      final output = await generate('CovariantChild');

      // Previously the interface extended `_$CovariantParentCWProxy`, so
      // `CovariantChild value(int value)` narrowed the inherited
      // `CovariantParent value(num value)` parameter, which Dart rejects.
      expect(output, isNot(contains('_\$CovariantParentCWProxy')));
      expect(
        output,
        contains('CovariantChild value(int value) => call(value: value);'),
      );
    });

    test(
      'child of an immutableFields parent generates its own field method',
      () async {
        final output = await generate('OpenChild');

        expect(output, contains('OpenChild a(int a) => call(a: a);'));
        expect(output, contains('OpenChild b(int b) => call(b: b);'));
      },
    );

    test(
      'immutableFields child of a mutable parent generates a bare call',
      () async {
        final output = await generate('LockedChild');

        // Previously the interface extended `_$OpenParentCWProxy`, so the
        // parameterless `call()` was an invalid override of `call({int a})`.
        expect(output, isNot(contains('_\$OpenParentCWProxy')));
        expect(output, contains('LockedChild call()'));
        expect(output, isNot(contains('LockedChild a(')));
      },
    );

    test(
      'fields from unannotated intermediates are generated locally',
      () async {
        final output = await generate('InheritanceProxyChild');

        expect(
          output,
          contains('InheritanceProxyChild base(int base) => call(base: base);'),
        );
        expect(
          output,
          contains(
            'InheritanceProxyChild middle(int middle) => call(middle: middle);',
          ),
        );
      },
    );
  });
}
