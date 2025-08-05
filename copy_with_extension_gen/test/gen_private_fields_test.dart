import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart' show expect, test, contains, isNot;

import 'gen_private_fields_parent.dart' as pp;

part 'gen_private_fields_test.g.dart';

@CopyWith()
class PrivateFields {
  const PrivateFields(this._hidden, this._hidden2, {required this.id});

  final int _hidden;
  final int? _hidden2;
  final int id;
}

@CopyWith()
class ChildWithPrivateSuper extends pp.PrivateParent {
  const ChildWithPrivateSuper(this.childField, [int s = 0]) : super(s);

  final int childField;
}

void main() {
  test('copyWith ignores private constructor parameters', () {
    const instance = PrivateFields(1, null, id: 1);
    final result = instance.copyWith(id: 2);
    expect(result._hidden, 1);
    expect(result._hidden2, null);
    expect(result.id, 2);
  });

  test('subclass skips private super fields from other libraries', () async {
    final content =
        await File('test/gen_private_fields_test.g.dart').readAsString();
    expect(content, isNot(contains('_secret')));

    const child = ChildWithPrivateSuper(1, 5);
    final copy = child.copyWith(childField: 2);
    expect(copy.childField, 2);
  });
}
