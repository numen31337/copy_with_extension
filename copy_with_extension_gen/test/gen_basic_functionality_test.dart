import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_basic_functionality_test.g.dart';

@CopyWith()
class CopyWithValues {
  const CopyWithValues({required this.id});

  final String id;
}

@CopyWith(copyWithNull: true)
class CopyWithValuesOptional {
  const CopyWithValuesOptional({this.id});

  final String? id;
}

@CopyWith()
class CopyWithProxy {
  const CopyWithProxy({this.id, this.immutable});

  final String? id;
  @CopyWithField(immutable: true)
  final String? immutable;
}

@CopyWith()
class CopyWithRenamedImmutable {
  const CopyWithRenamedImmutable({required int seed, required this.label})
      : immutable = seed;

  @CopyWithField(immutable: true)
  final int immutable;
  final String label;
}

@CopyWith()
class CopyWithProxyChaining {
  const CopyWithProxyChaining({this.id, this.field});

  final String? id;
  final String? field;
}

@CopyWith()
interface class CopyWithInterface {
  const CopyWithInterface({this.id});

  final int? id;
}

@CopyWith()
abstract mixin class CopyWithMixin {
  factory CopyWithMixin({required int id}) = _CopyWithMixinImpl;

  int get id;
}

class _CopyWithMixinImpl with CopyWithMixin {
  _CopyWithMixinImpl({required this.id});

  @override
  final int id;
}

void main() {
  group('CopyWithValues', () {
    test('updates field', () {
      expect(const CopyWithValues(id: '').copyWith(id: 'test').id, 'test');
    });
  });

  group('CopyWithValuesOptional', () {
    test('updates field', () {
      expect(const CopyWithValuesOptional().copyWith(id: 'test').id, 'test');
    });

    test('copyWithNull nullifies field', () {
      expect(
        const CopyWithValuesOptional(id: 'test').copyWithNull(id: true).id,
        null,
      );
    });

    test('proxy method accepts null', () {
      expect(
        const CopyWithValuesOptional(id: 'test').copyWith.id(null).id,
        null,
      );
    });

    test('call with explicit null', () {
      expect(
        const CopyWithValuesOptional(id: 'test').copyWith(id: null).id,
        null,
      );
    });

    test('no changes preserve value', () {
      expect(const CopyWithValuesOptional(id: 'test').copyWith().id, 'test');
    });
  });

  group('CopyWithProxy', () {
    test('proxy updates field', () {
      expect(const CopyWithProxy().copyWith.id('test').id, 'test');
    });

    test('proxy accepts null', () {
      expect(const CopyWithProxy(id: 'test').copyWith.id(null).id, null);
    });

    test('immutable field is preserved', () {
      const original = CopyWithProxy(immutable: 'init');
      final result = original.copyWith.id('new');

      expect(result.immutable, 'init');
    });
  });

  group('CopyWithRenamedImmutable', () {
    test('updating other fields preserves immutable resolved field', () {
      const original = CopyWithRenamedImmutable(seed: 1, label: 'old');
      final result = original.copyWith(label: 'new');

      expect(result.immutable, 1);
      expect(result.label, 'new');
    });

    test('immutable resolved field cannot be passed to call()', () {
      const original = CopyWithRenamedImmutable(seed: 1, label: 'old');
      final dynamic call = original.copyWith.call;

      expect(
        () => Function.apply(
          call as Function,
          const [],
          const {#immutable: 2},
        ),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });

  group('CopyWithProxyChaining', () {
    test('multiple proxy calls update fields', () {
      final result = const CopyWithProxyChaining()
          .copyWith
          .id('test')
          .copyWith
          .field('testField');

      expect(result.id, 'test');
      expect(result.field, 'testField');
    });
  });

  group('CopyWithInterface', () {
    test('updates field', () {
      expect(const CopyWithInterface().copyWith(id: 1).id, 1);
    });
  });

  group('CopyWithMixin', () {
    test('updates field', () {
      expect(CopyWithMixin(id: 1).copyWith(id: 2).id, 2);
    });
  });
}
