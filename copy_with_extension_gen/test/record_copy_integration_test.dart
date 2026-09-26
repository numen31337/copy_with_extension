import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'helpers/source_gen_test_utils.dart';

// These tests compile and call generated public APIs. Source comparison is
// deliberately limited to the separate existing class-output compatibility gate.
void main() {
  test(
    'records work in a clean consumer and survive edits and removal',
    () async {
      final consumer = await _Consumer.create();
      await consumer.write('lib/types.dart', '''
class Bound { const Bound(); }
class Child extends Bound { const Child(this.value); final int value; }
class Hidden {}
''');
      await consumer.write(
        'lib/barrel.dart',
        "export 'types.dart' show Bound, Child;\n",
      );
      await consumer.write('lib/models.dart', r'''
import 'dart:typed_data' as data;
import 'dart:typed_data' as bytes;
import 'package:copy_with_extension/copy_with_extension.dart' as c;
import 'barrel.dart' as models;
import 'types.dart' if (dart.library.io) 'types.dart' as conditional;
import 'types.dart' as ordinary;
part 'models.g.dart';
part 'record_part.dart';
@c.CopyWith(copyWithNull: true)
typedef Envelope<T extends models.Bound> = ({models.Child child, T tag, String? note});
@c.CopyWith()
typedef Alternate = ({data.Uint8List data});
@c.CopyWith()
typedef ConditionalAlternate = ({conditional.Child conditional});
bytes.Uint8List useAlternate() => bytes.Uint8List(0);
ordinary.Child useUnconditional() => const ordinary.Child(0);
''');
      await consumer.write('lib/record_part.dart', r'''
part of 'models.dart';
@c.CopyWith(copyWithNull: true)
typedef InPart = (models.Child, {String? label});
''');
      await consumer.write('lib/simple.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
import 'barrel.dart' show Child;
part 'simple.g.dart';
@CopyWith()
typedef Simple = ({Child child});
@CopyWith()
typedef Renamed<Value> = ({Value T});
''');
      await consumer.write('lib/aliases.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'aliases.g.dart';
@CopyWith()
typedef Mutable = ({int policy});
@CopyWith(immutableFields: true)
typedef Frozen = ({int policy});
''');
      await consumer.write('lib/public_models.dart', r'''
export 'models.dart' show Envelope, $EnvelopeCopyWith;
''');
      await consumer.write('lib/public_aliases.dart', r'''
export 'aliases.dart' hide $FrozenCopyWith;
''');
      await consumer.write('lib/coexist.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'coexist.g.dart';
@CopyWith()
typedef Row = ({int count});
@CopyWith()
class Holder {
  const Holder(this.row);
  final Row row;
}
''');
      await consumer.write('lib/scopes.dart', r'''
import 'dart:core';
import 'dart:core' as core;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'types.dart';
import 'types.dart' as F;
part 'scopes.g.dart';
@CopyWith()
typedef Callback = ({Child Function<F>() callback});
@CopyWith()
typedef AnnotationName = ({int override});
@CopyWith(skipFields: true)
typedef SkippedAnnotationName = ({int override});
@CopyWith()
typedef copyWith = ({int getterAlias});
@CopyWith()
typedef copyWithNull = ({int clearAlias});
core.Object useCore() => F.Child(0);
''');
      await consumer.write('lib/type_names.dart', r'''
class $ImportedCopyWith { const $ImportedCopyWith(this.value); final int value; }
''');
      await consumer.write('lib/imported_name.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
import 'type_names.dart' as models;
part 'imported_name.g.dart';
@CopyWith()
typedef Imported = ({models.$ImportedCopyWith child});
''');
      await consumer.write('bin/main.dart', r'''
import 'dart:typed_data';
import 'package:record_consumer/models.dart' as m;
import 'package:record_consumer/simple.dart';
import 'package:record_consumer/types.dart';
import 'package:record_consumer/public_aliases.dart' show Mutable, $MutableCopyWith;
import 'package:record_consumer/public_models.dart' as api;
import 'package:record_consumer/coexist.dart';
import 'package:record_consumer/scopes.dart';
import 'package:record_consumer/imported_name.dart';
import 'package:record_consumer/type_names.dart' as names;
void main() {
  m.Envelope<Child> value = (child: Child(1), tag: Child(2), note: 'old');
  final m.Envelope<Child> copy = m.$EnvelopeCopyWith<Child>(value).copyWith(child: Child(3));
  assert(copy.child.value == 3 && identical(copy.tag, value.tag));
  final api.Envelope<Child> exported = api.$EnvelopeCopyWith<Child>(value).copyWith(note: 'exported');
  assert(exported.note == 'exported' && identical(exported.child, value.child));
  assert(m.$EnvelopeCopyWith<Child>(value).copyWithNull(note: true).note == null);
  assert(m.$AlternateCopyWith((data: Uint8List(1))).copyWith(data: Uint8List(2)).data.length == 2);
  assert(m.$ConditionalAlternateCopyWith((conditional: Child(1))).copyWith(conditional: Child(2)).conditional.value == 2);
  assert(m.$InPartCopyWith((Child(1), label: 'old')).copyWithNull(label: true).label == null);
  assert($SimpleCopyWith((child: Child(1))).copyWith.child(Child(2)).child.value == 2);
  assert($RenamedCopyWith<String>((T: 'a')).copyWith(T: 'b').T == 'b');
  assert((policy: 1).copyWith(policy: 2).policy == 2);
  const Mutable mutable = (policy: 1);
  assert($MutableCopyWith(mutable).copyWith.policy(3).policy == 3);
  const holder = Holder((count: 1));
  final Holder replaced = holder.copyWith(row: holder.row.copyWith(count: 2));
  assert(replaced.row.count == 2 && holder.row.count == 1);
  Child callback<F>() => Child(9);
  final Callback functions = (callback: callback);
  assert(functions.copyWith(callback: callback).callback<int>().value == 9);
  assert($AnnotationNameCopyWith((override: 1)).copyWith.override(2).override == 2);
  assert($SkippedAnnotationNameCopyWith((override: 1)).copyWith(override: 2).override == 2);
  assert((getterAlias: 1).copyWith(getterAlias: 2).getterAlias == 2);
  assert((clearAlias: 1).copyWith(clearAlias: 2).clearAlias == 2);
  assert($ImportedCopyWith((child: names.$ImportedCopyWith(1))).copyWith(child: names.$ImportedCopyWith(2)).child.value == 2);
}
''');
      await consumer.get();
      await consumer.build();
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);

      // Actual input edit followed by an unchanged warm build: stale ownership
      // markers must neither reject our own declarations nor preserve old APIs.
      await consumer.write('lib/record_part.dart', r'''
part of 'models.dart';
@c.CopyWith()
typedef InPart = ({int edited});
''');
      await consumer.write('lib/coexist.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'coexist.g.dart';
@CopyWith()
typedef Row = ({int revision});
@CopyWith()
class Holder {
  const Holder(this.row, {this.note});
  final Row row;
  final String? note;
}
''');
      await consumer.write('bin/main.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_consumer/coexist.dart';
void main() {
  final InPart copy = (edited: 1).copyWith(edited: 2);
  assert(copy.edited == 2);
  const holder = Holder((revision: 1));
  final Holder changed = holder.copyWith(row: holder.row.copyWith(revision: 2), note: 'new');
  assert(changed.row.revision == 2 && changed.note == 'new');
  assert(holder.row.revision == 1 && holder.note == null);
}
''');
      await consumer.build();
      await consumer.build();
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.write('bin/obsolete.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_consumer/coexist.dart';
void obsolete(InPart record, Holder holder) {
  record.copyWith($1: null); // error:UNDEFINED_NAMED_PARAMETER
  record.copyWith.$1(null); // error:UNDEFINED_METHOD
  holder.row.copyWith(count: 2); // error:UNDEFINED_NAMED_PARAMETER
}
''');
      await consumer.diagnostics('bin/obsolete.dart');
      await consumer.write('bin/obsolete.dart', '');
      await consumer.write('lib/record_part.dart', "part of 'models.dart';\n");
      await consumer.write('lib/coexist.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'coexist.g.dart';
typedef Row = ({int revision});
@CopyWith()
class Holder {
  const Holder(this.row, {this.note});
  final Row row;
  final String? note;
}
''');
      await consumer.build();
      await consumer.write('bin/main.dart', r'''
import 'package:record_consumer/coexist.dart';
void main() {
  const holder = Holder((revision: 1), note: 'old');
  final Holder changed = holder.copyWith(row: (revision: 3), note: null);
  assert(changed.row.revision == 3 && changed.note == null);
  assert(holder.row.revision == 1 && holder.note == 'old');
}
''');
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.write('bin/removed.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_consumer/coexist.dart';
void removed(Envelope<dynamic> envelope, Holder holder) {
  print($InPartCopyWith((edited: 1))); // error:UNDEFINED_FUNCTION
  print($RowCopyWith(holder.row)); // error:UNDEFINED_FUNCTION
}
''');
      await consumer.diagnostics('bin/removed.dart');
      consumer.complete();
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  test(
    'a package consumer uses producer output and detects a stale dependency',
    () async {
      final producer = await _Consumer.create(name: 'record_producer');
      const model = r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'models.g.dart';
@CopyWith()
typedef Remote<T> = ({T payload, String? note});
''';
      await producer.write('lib/models.dart', model);
      await producer.write('lib/record_producer.dart', r'''
export 'models.dart' show Remote, $RemoteCopyWith;
''');
      await producer.get();
      await producer.build();
      await producer.success(['analyze', 'lib']);

      final consumer = await _Consumer.create(
        pathDependencies: {'record_producer': producer.directory.path},
      );
      await consumer.write('lib/models.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:record_producer/record_producer.dart' as p;
part 'models.g.dart';
@CopyWith()
typedef Local = ({p.Remote<int> remote, List<int> sibling});
''');
      await consumer.write('bin/main.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_producer/record_producer.dart' as p;
void main() {
  final Local original = (remote: (payload: 1, note: 'old'), sibling: [3]);
  final p.Remote<int> remote = p.$RemoteCopyWith<int>(original.remote).copyWith.payload(2);
  final Local changed = original.copyWith(remote: remote);
  assert(changed.remote.payload == 2 && changed.remote.note == 'old');
  assert(original.remote.payload == 1 && identical(changed.sibling, original.sibling));
}
''');
      await consumer.get();
      await consumer.build();
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.write('bin/invalid.dart', r'''
import 'package:record_producer/record_producer.dart' as p;
void takesString(String value) {}
void invalid(p.Remote<int> remote) {
  p.$RemoteCopyWith<int>(remote).copyWith(payload: 'wrong'); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  takesString(p.$RemoteCopyWith<int>(remote).copyWith.payload(2).payload); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
}
''');
      await consumer.diagnostics('bin/invalid.dart');
      await consumer.write('bin/invalid.dart', '');

      // A consumer build does not regenerate a dependency's checked-in output.
      // Enabling a new API must require regeneration in the producer package.
      await producer.write(
        'lib/models.dart',
        model.replaceFirst('@CopyWith()', '@CopyWith(copyWithNull: true)'),
      );
      await consumer.write('bin/stale.dart', r'''
import 'package:record_producer/record_producer.dart' as p;
void main() {
  const p.Remote<int> original = (payload: 1, note: 'old');
  final p.Remote<int> cleared = p.$RemoteCopyWith<int>(original).copyWithNull(note: true); // error:UNDEFINED_EXTENSION_METHOD
  assert(cleared.note == null && original.note == 'old');
}
''');
      await consumer.diagnostics('bin/stale.dart');
      await consumer.build();
      await consumer.diagnostics('bin/stale.dart');
      await producer.build();
      await producer.success(['analyze', 'lib']);
      await consumer.build();
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.success(['--enable-asserts', 'run', 'bin/stale.dart']);
      producer.complete();
      consumer.complete();
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  test(
    'strict public types and absent options reject invalid consumer calls',
    () async {
      final consumer = await _Consumer.create();
      await consumer.write('lib/models.dart', r'''
import 'dart:async';
import 'package:copy_with_extension/copy_with_extension.dart';
part 'models.g.dart';
@CopyWith(copyWithNull: true)
typedef Box<T> = ({T value});
@CopyWith(copyWithNull: true)
typedef Bounded<T extends num?> = ({T bounded});
@CopyWith(copyWithNull: true)
typedef Later<T> = ({FutureOr<T> later});
@CopyWith(copyWithNull: true)
typedef Row = ({int number, String? note, (int, String) inner});
@CopyWith(immutableFields: true)
typedef Frozen = ({int frozen});
@CopyWith(skipFields: true)
typedef Skipped = ({int skipped});
@CopyWith()
typedef NeverRow = ({Never impossible});
@CopyWith()
typedef A = ({int shape, String label});
@CopyWith(immutableFields: true)
typedef B = ({String label, int shape});
@CopyWith()
typedef Left = ({int left, num right});
@CopyWith()
typedef Right = ({num left, int right});
''');
      await consumer.write('lib/classes.dart', r'''
import 'dart:async' as a;
import 'package:copy_with_extension/copy_with_extension.dart';
part 'classes.g.dart';
@CopyWith(copyWithNull: true)
class GenericClass<T> {
  const GenericClass(this.value);
  final T value;
}
@CopyWith(copyWithNull: true)
class FutureClass<T> {
  const FutureClass(this.value);
  final a.FutureOr<T> value;
}
@CopyWith(copyWithNull: true)
class BoundedClass<T extends num?> {
  const BoundedClass(this.value);
  final T value;
}
@CopyWith(copyWithNull: true, skipFields: true)
class SkippedClass<T> {
  const SkippedClass(this.value);
  final a.FutureOr<T?> value;
}
@CopyWith(copyWithNull: true, immutableFields: true)
class FrozenClass<T> {
  const FrozenClass(this.value);
  final a.FutureOr<T?> value;
}
extension type MaybeText(String? representation) {}
@CopyWith()
class ExtensionClass {
  const ExtensionClass(this.value, this.later);
  final MaybeText value;
  final a.FutureOr<MaybeText> later;
}
''');
      await consumer.get();
      await consumer.build();
      await consumer.success(['analyze', 'lib']);
      await consumer.write('bin/main.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_consumer/classes.dart' as c;
void main() {
  const Box<String?> record = (value: 'old');
  const original = c.GenericClass<String?>('old');
  final c.GenericClass<String?> cleared = original.copyWith(value: null);
  assert(cleared.value == null && record.copyWith(value: null).value == null);
  assert(original.copyWith().value == 'old');
  final c.FutureClass<String?> future = const c.FutureClass<String?>('old').copyWith(value: null);
  assert(future.value == null);
  final c.BoundedClass<int?> bounded = const c.BoundedClass<int?>(1).copyWith.value(null);
  assert(bounded.value == null);
  final c.SkippedClass<int> skipped = const c.SkippedClass<int>(1).copyWithNull(value: true);
  assert(skipped.value == null);
}
''');
      await consumer.success(['analyze', 'bin/main.dart']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.write('bin/invalid.dart', r'''
import 'package:record_consumer/models.dart';
import 'package:record_consumer/classes.dart' as c;
void takesString(String value) {}
void invalidClasses(c.GenericClass<int> box, c.FutureClass<int> future, c.BoundedClass<int> bounded, c.SkippedClass<int> skipped, c.FrozenClass<int> frozen, c.ExtensionClass extension, c.GenericClass<c.MaybeText> erased) {
  box.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWith(value: 'bad'); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWith.value(null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  takesString(box.copyWith(value: 2).value); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  takesString(box.copyWith.value(2).value); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWithNull(value: true); // error:UNDEFINED_METHOD
  future.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  future.copyWith.value('bad'); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  future.copyWithNull(value: true); // error:UNDEFINED_METHOD
  bounded.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  bounded.copyWithNull(value: true); // error:UNDEFINED_METHOD
  skipped.copyWith.value(2); // error:UNDEFINED_METHOD
  frozen.copyWith(value: null); // error:UNDEFINED_NAMED_PARAMETER
  frozen.copyWithNull(value: true); // error:UNDEFINED_METHOD
  extension.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  extension.copyWith(later: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  erased.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
}
void invalid(Box<int> box, Bounded<int> bounded, Later<int> later, Row row, Frozen frozen, Skipped skipped, NeverRow bottom, A equal, ({int left, int right}) overlap) {
  box.copyWith(value: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWith.value('bad'); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWith.value(null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  takesString(box.copyWith(value: 2).value); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  takesString(box.copyWith.value(2).value); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  box.copyWithNull(value: true); // error:UNDEFINED_METHOD
  bounded.copyWithNull(bounded: true); // error:UNDEFINED_METHOD
  later.copyWithNull(later: true); // error:UNDEFINED_METHOD
  row.copyWith(number: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  row.copyWith(number: 'bad'); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  row.copyWith(inner: ('bad', 1)); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  row.copyWithNull(number: true); // error:UNDEFINED_NAMED_PARAMETER
  frozen.copyWith(frozen: 2); // error:UNDEFINED_NAMED_PARAMETER
  skipped.copyWith.skipped(2); // error:UNDEFINED_METHOD
  bottom.copyWith(impossible: null); // error:ARGUMENT_TYPE_NOT_ASSIGNABLE
  equal.copyWith(shape: 2); // error:AMBIGUOUS_EXTENSION_MEMBER_ACCESS
  overlap.copyWith(left: 2); // error:AMBIGUOUS_EXTENSION_MEMBER_ACCESS
}
''');
      await consumer.diagnostics('bin/invalid.dart');
      consumer.complete();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test('unsupported declarations fail at the annotated source', () async {
    final consumer = await _Consumer.create();
    final expected = <String, (String, String)>{};
    for (final entry in _invalidDeclarations.entries) {
      final file = 'lib/${entry.key}.dart';
      final source = entry.value.$1;
      // These fixtures optionally supply one leading import.
      final importEnd =
          source.startsWith('import ') ? source.indexOf(';') + 1 : 0;
      await consumer.write(file, '''
import 'package:copy_with_extension/copy_with_extension.dart';
${source.substring(0, importEnd)}
part '${entry.key}.g.dart';
${source.substring(importEnd)}
''');
      expected[file] = (entry.value.$2, entry.value.$3);
    }
    final routes = {
      'hidden_placeholder':
          "import 'package:copy_with_extension/copy_with_extension.dart' show CopyWith;",
      'conditional':
          "import 'package:copy_with_extension/copy_with_extension.dart'; import 'types.dart' if (dart.library.io) 'types.dart' as types;",
      'conditional_export':
          "import 'package:copy_with_extension/copy_with_extension.dart'; import 'conditional_barrel.dart' as types;",
      'deferred':
          "import 'package:copy_with_extension/copy_with_extension.dart'; import 'types.dart' deferred as types;",
      'prefix_capture':
          "import 'package:copy_with_extension/copy_with_extension.dart'; import 'types.dart' as types;",
    };
    await consumer.write('lib/types.dart', 'class Bound {} class Child {}');
    await consumer.write(
      'lib/conditional_barrel.dart',
      "export 'types.dart' if (dart.library.io) 'types.dart';\n",
    );
    await consumer.write(
      'lib/imported_collision.dart',
      r'class $InvalidCopyWith {}',
    );
    for (final entry in routes.entries) {
      final type =
          entry.key == 'hidden_placeholder'
              ? 'int value'
              : entry.key == 'prefix_capture'
              ? 'types.Child types'
              : 'types.Child value';
      final file = 'lib/${entry.key}.dart';
      await consumer.write(
        file,
        "${entry.value}\npart '${entry.key}.g.dart';\n@CopyWith() typedef Invalid = ({$type});\n",
      );
      expected[file] =
          entry.key == 'hidden_placeholder'
              ? (r'cannot reference "$CopyWithPlaceholder"', '({int value})')
              : ('cannot reference "Child"', 'types.Child');
    }
    await consumer.write('lib/metadata_in_part.dart', '''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'metadata_in_part.g.dart';
part 'metadata_part.dart';
''');
    await consumer.write('lib/metadata_part.dart', '''
part of 'metadata_in_part.dart';
@CopyWith() typedef Invalid = ({@Deprecated('old') int value});
''');
    expected['lib/metadata_in_part.dart'] = (
      'Metadata on record component "value"',
      '@Deprecated',
    );
    await consumer.write('lib/unresolved_annotation.dart', '''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'unresolved_annotation.g.dart';
@CopyWith(immutableFields: missingOption) // error:CONST_WITH_NON_CONSTANT_ARGUMENT error:UNDEFINED_IDENTIFIER
typedef UpstreamError = ({int value});
''');
    await consumer.get();
    final result = await consumer.run(['run', 'build_runner', 'build']);
    final output = '${result.stdout}\n${result.stderr}';
    consumer.check(result.exitCode, isNot(0), output);
    consumer.check(
      RegExp(
        r'^E [^\r\n]+',
        multiLine: true,
      ).allMatches(output).map((match) => match[0]),
      unorderedEquals([
        for (final file in expected.keys) 'E copy_with_extension_gen on $file:',
      ]),
      output,
    );
    for (final entry in expected.entries) {
      final start = output.indexOf('on ${entry.key}:');
      consumer.check(start, greaterThanOrEqualTo(0), output);
      final end = output.indexOf('\nE ', start + 1);
      final diagnostic = output.substring(start, end < 0 ? output.length : end);
      consumer.check(diagnostic, contains(entry.value.$1), output);
      final source =
          entry.key == 'lib/metadata_in_part.dart'
              ? 'lib/metadata_part.dart'
              : entry.key;
      final content =
          File('${consumer.directory.path}/$source').readAsStringSync();
      final offset = content.indexOf(entry.value.$2);
      consumer.check(offset, greaterThanOrEqualTo(0), content);
      final before = content.substring(0, offset);
      final line = '\n'.allMatches(before).length + 1;
      final column = before.length - before.lastIndexOf('\n');
      consumer.check(
        RegExp(
              r'^\s+(?:asset:record_consumer/|package:record_consumer/)(\S+:\d+:\d+)\s*$',
              multiLine: true,
            )
            .allMatches(diagnostic)
            .map((match) => match[1]!.replaceFirst(RegExp(r'^lib/'), '')),
        equals(['${source.substring(4)}:$line:$column']),
        output,
      );
    }
    // A build can still emit a part for malformed annotation arguments. The
    // compiler must report the original user's constant/name errors, not an
    // accidental error in a generated helper.
    await consumer.diagnostics('lib/unresolved_annotation.dart');
    consumer.complete();
  }, timeout: const Timeout(Duration(minutes: 3)));

  test(
    'global policies and explicit annotation overrides use public APIs',
    () async {
      final consumer = await _Consumer.create();
      await consumer.write('build.yaml', r'''
targets:
  $default:
    builders:
      copy_with_extension_gen:
        options:
          immutable_fields: true
          skip_fields: true
          copy_with_null: true
''');
      await consumer.write('lib/models.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'models.g.dart';
@CopyWith()
typedef Frozen = ({int fixed});
@CopyWith(immutableFields: false, skipFields: false)
typedef Mutable = ({String? mutable});
@CopyWith(immutableFields: false, copyWithNull: false)
typedef NoClear = ({String? noClear});
''');
      await consumer.write('bin/main.dart', r'''
import 'package:record_consumer/models.dart';
void main() {
  assert((fixed: 1).copyWith() == (fixed: 1));
  assert((mutable: 'old').copyWith.mutable('new').mutable == 'new');
  assert((mutable: 'old').copyWithNull(mutable: true).mutable == null);
  assert((noClear: 'old').copyWith(noClear: null).noClear == null);
}
''');
      await consumer.get();
      await consumer.build();
      await consumer.success(['analyze', 'lib', 'bin']);
      await consumer.success(['--enable-asserts', 'run', 'bin/main.dart']);
      await consumer.write('bin/invalid.dart', r'''
import 'package:record_consumer/models.dart';
void invalid(Frozen frozen, NoClear noClear) {
  frozen.copyWith(fixed: 2); // error:UNDEFINED_NAMED_PARAMETER
  noClear.copyWith.noClear('new'); // error:UNDEFINED_METHOD
  noClear.copyWithNull(noClear: true); // error:UNDEFINED_METHOD
}
''');
      await consumer.diagnostics('bin/invalid.dart');
      consumer.complete();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test('a different builder cannot own a record helper name', () async {
    final consumer = await _Consumer.create();
    await consumer.write('build.yaml', r'''
builders:
  foreign:
    import: "tool/foreign_builder.dart"
    builder_factories: ["foreign"]
    build_extensions: {".seed": [".other.g.dart"]}
    auto_apply: root_package
    build_to: source
    runs_before: ["copy_with_extension_gen:copy_with_extension_gen"]
''');
    await consumer.write('tool/foreign_builder.dart', r'''
import 'package:build/build.dart';
Builder foreign(BuilderOptions options) => ForeignBuilder();
class ForeignBuilder implements Builder {
  @override
  final buildExtensions = const {'.seed': ['.other.g.dart']};
  @override
  Future<void> build(BuildStep step) async {
    await step.writeAsString(step.inputId.changeExtension('.other.g.dart'),
      "part of 'collision.dart';\nclass " + r'$ForeignCopyWith' + " {}\n");
  }
}
''');
    await consumer.write('lib/foreign.seed', 'foreign generator input');
    await consumer.write(
      'lib/collision.dart',
      "part 'foreign.other.g.dart';\n",
    );
    await consumer.get();
    await consumer.build();
    await consumer.success(['analyze', 'lib']);
    await consumer.write('lib/collision.dart', r'''
import 'package:copy_with_extension/copy_with_extension.dart';
part 'foreign.other.g.dart';
part 'collision.g.dart';
@CopyWith()
typedef Foreign = ({int value});
''');
    final result = await consumer.run(['run', 'build_runner', 'build']);
    final output = '${result.stdout}\n${result.stderr}';
    consumer.check(result.exitCode, isNot(0), output);
    consumer.check(
      RegExp(
        r'^E [^\r\n]+',
        multiLine: true,
      ).allMatches(output).map((match) => match[0]),
      equals(['E copy_with_extension_gen on lib/collision.dart:']),
      output,
    );
    consumer.check(
      output,
      contains(r'Generated record declaration "$ForeignCopyWith" conflicts'),
      output,
    );
    consumer.check(
      output,
      matches(
        r'(?:asset:record_consumer/lib/|package:record_consumer/)foreign\.other\.g\.dart:2:7\r?\n',
      ),
      output,
    );
    // A later builder's assets are not visible to this generator. The user's
    // final analysis must still catch that separate, cross-builder conflict.
    final configuration = File('${consumer.directory.path}/build.yaml');
    await consumer.write(
      'build.yaml',
      configuration.readAsStringSync().replaceAll(
        '    runs_before: ["copy_with_extension_gen:copy_with_extension_gen"]\n',
        '',
      ),
    );
    await consumer.build();
    final analysis = await consumer.run(['analyze', '--format=machine', 'lib']);
    final diagnostics =
        '${analysis.stdout}\n${analysis.stderr}'
            .split('\n')
            .where((line) => line.contains('|'))
            .toList();
    consumer.check(analysis.exitCode, isNot(0), diagnostics.join('\n'));
    consumer.check(diagnostics, hasLength(1), diagnostics.join('\n'));
    consumer.check(
      diagnostics.single,
      matches(
        '^ERROR\\|COMPILE_TIME_ERROR\\|DUPLICATE_DEFINITION\\|'
        '${RegExp.escape(consumer.directory.path)}/lib/collision.g.dart\\|[0-9]+\\|',
      ),
      diagnostics.join('\n'),
    );
    consumer.complete();
  }, timeout: const Timeout(Duration(minutes: 3)));
}

// The third value identifies the exact source token that should be diagnosed.
const _invalidDeclarations = <String, (String, String, String)>{
  'nullable_future_inheritance': (
    "import 'dart:async'; @CopyWith(copyWithNull: true) class Parent<T> { const Parent(this.value); final FutureOr<T?> value; } @CopyWith() class Invalid<T> extends Parent<T> { const Invalid(super.value); }",
    'but does not enable `copyWithNull` itself',
    'Invalid<T> extends',
  ),
  'nullable_distant_inheritance': (
    "import 'dart:async'; @CopyWith(copyWithNull: true) class Grandparent { const Grandparent(this.value); final int? value; } @CopyWith(copyWithNull: true, immutableFields: true) class Parent extends Grandparent { const Parent(super.value); } @CopyWith() class Invalid extends Parent { const Invalid(super.value, this.later); final FutureOr<int?> later; }",
    'but does not enable `copyWithNull` itself',
    'Invalid extends',
  ),
  'nullable_interface_inheritance': (
    "import 'dart:async'; @CopyWith(copyWithNull: true) class Parent<T> { const Parent(this.value); final T value; } @CopyWith(copyWithNull: true) class Interface { const Interface(this.note); final String? note; } @CopyWith() class Invalid extends Parent<int> implements Interface { const Invalid(super.value, this.note, this.later); @override final String? note; final FutureOr<int?> later; }",
    'but does not enable `copyWithNull` itself',
    'Invalid extends',
  ),
  'extension_prefix': (
    r"import 'types.dart' as $InvalidCopyWith; @CopyWith() typedef Invalid = ({$InvalidCopyWith.Child child});",
    'conflicts with an import prefix',
    r'$InvalidCopyWith;',
  ),
  'proxy_prefix': (
    r"import 'types.dart' as _$InvalidCWProxy; @CopyWith() typedef Invalid = ({_$InvalidCWProxy.Child child});",
    'conflicts with an import prefix',
    r'_$InvalidCWProxy;',
  ),
  'implementation_prefix': (
    r"import 'types.dart' as _$InvalidCWProxyImpl; @CopyWith() typedef Invalid = ({_$InvalidCWProxyImpl.Child child});",
    'conflicts with an import prefix',
    r'_$InvalidCWProxyImpl;',
  ),
  'imported_name': (
    r"import 'imported_collision.dart'; @CopyWith() typedef Invalid = ({$InvalidCopyWith child});",
    'conflicts with an unprefixed imported declaration',
    'Invalid =',
  ),
  'never_capture': (
    '@CopyWith() typedef Invalid = ({Never Never});',
    'cannot reference "Never"',
    'Never Never',
  ),
  'override_capture': (
    '@CopyWith() typedef Invalid = ({int override});',
    'cannot reference "override"',
    '({int override})',
  ),
  'extension_alias_capture': (
    '@CopyWith(copyWithNull: true) typedef copyWith = ({int? value});',
    'alias "copyWith" is shadowed',
    'copyWith =',
  ),
  'not_record': (
    '@CopyWith() typedef Invalid = int;',
    'requires a direct record typedef',
    'int;',
  ),
  'alias_chain': (
    'typedef Inner = ({int value}); @CopyWith() typedef Invalid = Inner;',
    'requires a direct record typedef',
    'Inner;',
  ),
  'nullable_root': (
    '@CopyWith() typedef Invalid = ({int value})?;',
    'Nullable record typedef roots',
    '({int value})?',
  ),
  'constructor': (
    "@CopyWith(constructor: 'named') typedef Invalid = ({int value});",
    'has no constructor',
    'Invalid =',
  ),
  'empty_constructor': (
    "@CopyWith(constructor: '') typedef Invalid = ({int value});",
    'has no constructor',
    'Invalid =',
  ),
  'void': (
    '@CopyWith() typedef Invalid = ({void value});',
    'Immediate void-typed record component',
    'void value',
  ),
  'void_alias': (
    'typedef Nothing = void; @CopyWith() typedef Invalid = ({Nothing value});',
    'Immediate void-typed record component',
    'Nothing value',
  ),
  'metadata_named': (
    "@CopyWith() typedef Invalid = ({int z, @Deprecated('old') int a});",
    'Metadata on record component "a"',
    '@Deprecated',
  ),
  'metadata_positional': (
    "@CopyWith() typedef Invalid = (@Deprecated('old') int,);",
    r'Metadata on record component "$1"',
    '@Deprecated',
  ),
  'call': (
    '@CopyWith() typedef Invalid = ({int call});',
    'conflicts with the callable proxy',
    'int call',
  ),
  'type_parameter': (
    '@CopyWith() typedef Invalid<T> = ({T T});',
    'type parameter "T" conflicts',
    'Invalid<',
  ),
  'type_parameter_skip': (
    '@CopyWith(skipFields: true) typedef Invalid<T> = ({T T});',
    'cannot reference "T"',
    'T T',
  ),
  'value_parameter': (
    '@CopyWith() typedef Invalid<_value> = ({_value value});',
    'type parameter "_value" conflicts',
    'Invalid<',
  ),
  'copy_parameter': (
    '@CopyWith() typedef Invalid<copyWith> = ({copyWith value});',
    'type parameter "copyWith" conflicts',
    'Invalid<',
  ),
  'alias_capture': (
    '@CopyWith() typedef Invalid = ({int Invalid});',
    'alias "Invalid" is shadowed',
    'Invalid =',
  ),
  'placeholder_capture': (
    r'@CopyWith() typedef Invalid = ({int $CopyWithPlaceholder});',
    r'cannot reference "$CopyWithPlaceholder"',
    r'({int $CopyWithPlaceholder})',
  ),
  'name_collision': (
    r'class $InvalidCopyWith {} @CopyWith() typedef Invalid = ({int value});',
    'conflicts with an existing declaration',
    r'$InvalidCopyWith {}',
  ),
  'proxy_collision': (
    r'class _$InvalidCWProxy {} @CopyWith() typedef Invalid = ({int value});',
    'conflicts with an existing declaration',
    r'_$InvalidCWProxy {}',
  ),
  'proxy_parameter': (
    r'@CopyWith() typedef Invalid<_$InvalidCWProxy> = ({_$InvalidCWProxy value});',
    'conflicts with a generated declaration',
    'Invalid<',
  ),
};

class _Consumer {
  _Consumer(this.directory, this.versions);

  final Directory directory;
  final Map<String, String> versions;
  var _command = 0;
  var _failed = false;
  var _completed = false;
  var _closed = false;
  Process? _process;
  Future<void>? _commandFinished;

  void complete() => _completed = true;

  void check(Object? actual, Matcher matcher, String reason) {
    if (!matcher.matches(actual, {})) _failed = true;
    expect(actual, matcher, reason: reason);
  }

  static Future<_Consumer> create({
    String name = 'record_consumer',
    Map<String, String> pathDependencies = const {},
  }) async {
    final generator = Directory(resolvePackagePath('')).absolute;
    final annotation = '${generator.parent.path}/copy_with_extension';
    final lock =
        File('${generator.parent.path}/pubspec.lock').readAsStringSync();
    final versions = _hostedVersions(lock);
    final created = await Directory.systemTemp.createTemp('record_consumer_');
    final directory = Directory(created.resolveSymbolicLinksSync());
    final consumer = _Consumer(directory, versions);
    addTearDown(() async {
      consumer._closed = true;
      consumer._process?.kill();
      await consumer._commandFinished?.timeout(
        const Duration(seconds: 10),
        onTimeout:
            () =>
                throw TimeoutException(
                  'Consumer did not stop; retained at ${directory.path}',
                ),
      );
      final evidenceRoot = Platform.environment['COPY_WITH_TEST_EVIDENCE'];
      if (evidenceRoot != null) {
        final destination = Directory(
          '$evidenceRoot/${directory.uri.pathSegments.where((s) => s.isNotEmpty).last}',
        );
        await _retainConsumer(directory, destination);
      }
      if (consumer._failed || !consumer._completed) {
        print('Failed consumer and command logs retained at ${directory.path}');
      } else {
        await directory.delete(recursive: true);
      }
    });
    await consumer.write('pubspec.yaml', '''
name: $name
publish_to: none
environment:
  sdk: ^3.7.0
dependencies:
  copy_with_extension:
    path: ${jsonEncode(annotation)}
${pathDependencies.entries.map((e) => '  ${e.key}:\n    path: ${jsonEncode(e.value)}').join('\n')}
dev_dependencies:
  copy_with_extension_gen:
    path: ${jsonEncode(generator.path)}
  build_runner: any
dependency_overrides:
  copy_with_extension:
    path: ${jsonEncode(annotation)}
${versions.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}
''');
    return consumer;
  }

  Future<void> write(String path, String content) async {
    final file = File('${directory.path}/$path');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  Future<ProcessResult> run(List<String> arguments) async {
    if (_closed) throw StateError('Consumer is closed');
    final log = 'logs/${++_command}.txt';
    final command = arguments.join(' ');
    final finished = Completer<void>();
    _commandFinished = finished.future;
    try {
      await write(log, '$command\nstarted\n');
      final process = await Process.start(
        Platform.resolvedExecutable,
        arguments,
        workingDirectory: directory.path,
      );
      _process = process;
      if (_closed) {
        process.kill();
        await process.exitCode;
        throw StateError('Consumer closed while starting a process');
      }
      final output = process.stdout.transform(utf8.decoder).join();
      final errors = process.stderr.transform(utf8.decoder).join();
      final result = ProcessResult(
        process.pid,
        await process.exitCode,
        await output,
        await errors,
      );
      await write(
        log,
        '$command\nexit: ${result.exitCode}\n${result.stdout}\n${result.stderr}',
      );
      return result;
    } catch (error, stack) {
      await write(log, '$command\nfailed: $error\n$stack');
      rethrow;
    } finally {
      _process = null;
      finished.complete();
    }
  }

  Future<void> success(List<String> arguments) async {
    final result = await run(arguments);
    check(
      result.exitCode,
      equals(0),
      '${directory.path}: $arguments\n${result.stdout}\n${result.stderr}',
    );
  }

  Future<void> get() async {
    await success(['pub', 'get']);
    final selected = _hostedVersions(
      File('${directory.path}/pubspec.lock').readAsStringSync(),
    );
    check(
      selected,
      equals(versions),
      'Consumer must use the workspace dependency lane',
    );
  }

  Future<void> build() => success(['run', 'build_runner', 'build']);

  Future<void> diagnostics(String path) async {
    final source = File('${directory.path}/$path').readAsLinesSync();
    final expected = <String>[];
    for (var i = 0; i < source.length; i++) {
      for (final marker in RegExp(r'error:(\w+)').allMatches(source[i])) {
        expected.add('ERROR:COMPILE_TIME_ERROR:${i + 1}:${marker[1]}');
      }
    }
    final result = await run(['analyze', '--format=machine', path]);
    final actual = <String>[];
    for (final line in '${result.stdout}\n${result.stderr}'.split('\n')) {
      final parts = line.split('|');
      if (parts.length < 8) continue;
      // Include warnings and errors: an unrelated generated diagnostic is not
      // evidence that the intended invalid public call was rejected.
      actual.add('${parts[0]}:${parts[1]}:${parts[4]}:${parts[2]}');
      if (parts[3] != '${directory.path}/$path') _failed = true;
    }
    actual.sort();
    expected.sort();
    check(result.exitCode, isNot(0), '${result.stdout}\n${result.stderr}');
    check(actual, equals(expected), '${result.stdout}\n${result.stderr}');
    expect(
      _failed,
      isFalse,
      reason: 'Diagnostics must come from the expected source',
    );
  }
}

Map<String, String> _hostedVersions(String lock) => {
  for (final match in RegExp(
    r'^  (\w+):\n((?: {4}[^\n]*\n)+)',
    multiLine: true,
  ).allMatches(lock))
    if (match[2]!.contains('source: hosted'))
      match[1]!: RegExp(r'version: "([^"]+)"').firstMatch(match[2]!)![1]!,
};

// Optional acceptance-run artifacts; cache binaries are not useful evidence.
Future<void> _retainConsumer(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list(followLinks: false)) {
    final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (name == '.dart_tool') {
      final config = File('${entity.path}/package_config.json');
      if (await config.exists()) {
        await config.copy('${destination.path}/package_config.json');
      }
    } else if (entity is Directory) {
      await _retainConsumer(entity, Directory('${destination.path}/$name'));
    } else if (entity is File) {
      await entity.copy('${destination.path}/$name');
    }
  }
}
