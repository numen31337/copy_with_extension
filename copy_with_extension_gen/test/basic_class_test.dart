import 'package:analyzer/dart/analysis/results.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

import 'test_classes/basic_class.dart';

void main() {
  test('has no issue', () async {
    final main = await resolveSources(
      {
        'copy_with_extension_gen|test/test_classes/basic_class.dart':
            useAssetReader,
      },
      (r) => r.libraries.firstWhere(
        (element) => element.source.toString().contains('basic_class'),
      ),
    );

    final errorResult = await main.session.getErrors(
            '/copy_with_extension_gen/test/test_classes/basic_class.g.dart')
        as ErrorsResult;

    expect(errorResult.errors, isEmpty);
  });

  test('BasicClass test', () {
    const basicClass = BasicClass(
      id: '',
      immutable: 0,
      nullableImmutable: 0,
    );

    expect(basicClass.copyWith.id("test").id, "test");
  });
}
