import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'helpers/source_gen_test_utils.dart';

/// Reproduce with Dart 3.13+:
/// `dart test test/primary_constructor_integration_test.dart`.
void main() {
  test(
    'primary constructors work through the public package workflow',
    () async {
      final generatorRoot = Directory(resolvePackagePath('')).absolute;
      final annotationRoot = Directory(
        '${generatorRoot.parent.path}${Platform.pathSeparator}'
        'copy_with_extension',
      );
      final consumer = await Directory.systemTemp.createTemp(
        'copy_with_extension_primary_constructor_',
      );
      addTearDown(() => consumer.delete(recursive: true));

      await _writeConsumerPackage(
        consumer,
        annotationRoot: annotationRoot,
        generatorRoot: generatorRoot,
      );

      await _expectSuccess(consumer, const ['pub', 'get']);
      final build = await _run(consumer, const [
        'run',
        'build_runner',
        'build',
      ]);
      final buildOutput = _output(build);
      expect(build.exitCode, 0, reason: buildOutput);
      expect(
        buildOutput,
        isNot(contains('constructor binding analysis will be limited')),
        reason: buildOutput,
      );
      await _expectSuccess(consumer, const ['analyze']);
      await _expectSuccess(consumer, const ['test']);

      await _writeDerivedMapping(consumer);
      final derivedBuild = await _run(consumer, const [
        'run',
        'build_runner',
        'build',
      ]);
      final derivedOutput = _output(derivedBuild);
      expect(derivedBuild.exitCode, isNot(0), reason: derivedOutput);
      expect(
        derivedOutput,
        contains(
          'Constructor parameter "seed" in class DerivedPrimary could not be '
          'resolved to exactly one accessible class field.',
        ),
        reason: derivedOutput,
      );
    },
    skip:
        _supportsPrimaryConstructors
            ? false
            : 'Primary constructors require Dart 3.13 or later.',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

final bool _supportsPrimaryConstructors = () {
  final match = RegExp(r'^(\d+)\.(\d+)').firstMatch(Platform.version);
  if (match == null) {
    return false;
  }
  final major = int.parse(match.group(1)!);
  final minor = int.parse(match.group(2)!);
  return major > 3 || major == 3 && minor >= 13;
}();

Future<void> _writeConsumerPackage(
  Directory consumer, {
  required Directory annotationRoot,
  required Directory generatorRoot,
}) async {
  final lib = Directory('${consumer.path}${Platform.pathSeparator}lib')
    ..createSync();
  final test = Directory('${consumer.path}${Platform.pathSeparator}test')
    ..createSync();

  await File(
    '${consumer.path}${Platform.pathSeparator}pubspec.yaml',
  ).writeAsString('''
name: primary_constructor_consumer
publish_to: none

environment:
  sdk: ">=3.13.0 <4.0.0"

dependencies:
  copy_with_extension:
    path: ${jsonEncode(annotationRoot.path)}

dev_dependencies:
  build_runner: ^2.10.0
  copy_with_extension_gen:
    path: ${jsonEncode(generatorRoot.path)}
  test: ^1.26.3

dependency_overrides:
  copy_with_extension:
    path: ${jsonEncode(annotationRoot.path)}
''');

  await File('${lib.path}${Platform.pathSeparator}models.dart').writeAsString(
    r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'models.g.dart';

@CopyWith()
class DeclaringPrimary(
  final String finalValue,
  var String mutable,
  @CopyWithField(immutable: true) final String immutable,
);

@CopyWith(constructor: 'named')
class NamedPrimary.named(final String value);

@CopyWith(constructor: 'create')
class RedirectedPrimary._(final String value) {
  factory RedirectedPrimary.create(String value) = RedirectedPrimary._;
}

class PrimaryBase(final String base);

@CopyWith()
class PrimaryChild(super.base, final int own) extends PrimaryBase;

class ExplicitBase(final String base);

@CopyWith()
class ExplicitSuperPrimary(String seed) extends ExplicitBase {
  this : super(seed);
}

@CopyWith()
class GenericPrimary<T>(final T value);

@CopyWith()
class FieldAliasPrimary(String seed) {
  final String id = seed;
}

@CopyWith()
class InitializerAliasPrimary(String seed) {
  final String id;

  this : id = seed;
}

@CopyWith()
class ConciseConstructor {
  new(this.value);

  final String value;
}
''',
  );

  await File(
    '${test.path}${Platform.pathSeparator}models_test.dart',
  ).writeAsString(r'''
import 'package:primary_constructor_consumer/models.dart';
import 'package:test/test.dart';

void main() {
  test('generated copyWith APIs work from a consumer package', () {
    final declaring = DeclaringPrimary('old final', 'old mutable', 'fixed')
        .copyWith(
      finalValue: 'new final',
      mutable: 'new mutable',
    );
    expect(declaring, isA<DeclaringPrimary>());
    expect(declaring.finalValue, 'new final');
    expect(declaring.immutable, 'fixed');
    expect(declaring.mutable, 'new mutable');
    final dynamic declaringCall = declaring.copyWith.call;
    expect(
      () => Function.apply(
        declaringCall as Function,
        const [],
        const {#immutable: 'changed'},
      ),
      throwsA(isA<NoSuchMethodError>()),
    );

    final named = NamedPrimary.named('old').copyWith(value: 'new');
    expect(named, isA<NamedPrimary>());
    expect(named.value, 'new');

    final redirected = RedirectedPrimary.create('old').copyWith(value: 'new');
    expect(redirected, isA<RedirectedPrimary>());
    expect(redirected.value, 'new');

    final child = PrimaryChild('old', 1).copyWith(base: 'new', own: 2);
    expect(child, isA<PrimaryChild>());
    expect(child.base, 'new');
    expect(child.own, 2);

    final explicitSuper = ExplicitSuperPrimary('old').copyWith(base: 'new');
    expect(explicitSuper, isA<ExplicitSuperPrimary>());
    expect(explicitSuper.base, 'new');

    final generic = GenericPrimary<int>(1).copyWith(value: 2);
    expect(generic, isA<GenericPrimary<int>>());
    expect(generic.value, 2);

    final fieldAlias = FieldAliasPrimary('old').copyWith(id: 'new');
    expect(fieldAlias, isA<FieldAliasPrimary>());
    expect(fieldAlias.id, 'new');

    final initializerAlias = InitializerAliasPrimary('old').copyWith(id: 'new');
    expect(initializerAlias, isA<InitializerAliasPrimary>());
    expect(initializerAlias.id, 'new');

    final concise = ConciseConstructor('old').copyWith(value: 'new');
    expect(concise, isA<ConciseConstructor>());
    expect(concise.value, 'new');
  });
}
''');
}

Future<void> _writeDerivedMapping(Directory consumer) async {
  await File(
    '${consumer.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}models.dart',
  ).writeAsString(r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'models.g.dart';

@CopyWith()
class DerivedPrimary(String seed) {
  final String id = seed.trim();
}
''');
  await File(
    '${consumer.path}${Platform.pathSeparator}test'
    '${Platform.pathSeparator}models_test.dart',
  ).writeAsString("void main() {}\n");
}

Future<ProcessResult> _run(Directory consumer, List<String> arguments) {
  return Process.run(
    Platform.resolvedExecutable,
    arguments,
    workingDirectory: consumer.path,
  );
}

Future<void> _expectSuccess(Directory consumer, List<String> arguments) async {
  final result = await _run(consumer, arguments);
  expect(result.exitCode, 0, reason: _output(result));
}

String _output(ProcessResult result) => '${result.stdout}\n${result.stderr}';
