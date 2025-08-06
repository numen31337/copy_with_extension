import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

part 'gen_positioned_ctor_fields_test.g.dart';

@CopyWith()
class PositionedFields extends Equatable {
  const PositionedFields(this.one, this.oneAndAHalf, {this.two});

  final String one;
  final String oneAndAHalf;
  final String? two;

  @override
  List<Object?> get props => [one, oneAndAHalf, two];
}

void main() {
  group('$PositionedFields', () {
    late PositionedFields instance;

    setUp(() {
      instance = const PositionedFields('one', 'oneAndAHalf', two: 'two');
    });

    test('one is replaced value', () {
      const expected = PositionedFields('test', 'oneAndAHalf', two: 'two');

      expect(instance.copyWith.one('test'), expected);
    });

    test('oneAndAHalf is replaced value', () {
      const expected = PositionedFields('one', 'test', two: 'two');

      expect(instance.copyWith.oneAndAHalf('test'), expected);
    });

    test('two is replaced value', () {
      const expected = PositionedFields('one', 'oneAndAHalf', two: 'test');

      expect(instance.copyWith.two('test'), expected);
    });
  });
}
