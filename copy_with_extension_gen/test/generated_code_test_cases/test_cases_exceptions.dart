part of 'source_gen_entrypoint.dart';

@ShouldThrow(
  'Only classes can be annotated with "CopyWith". "Object wrongAnnotation" is not a ClassElement.',
)
// ignore: invalid_annotation_target
@CopyWith()
Object wrongAnnotation = Object();

@ShouldThrow(
  'Unnamed constructor for NoConstructor has no parameters or missing.',
)
@CopyWith()
class NoConstructor {
  int? test;
}

@ShouldThrow('Named Constructor "test" constructor is missing.')
@CopyWith(constructor: "test")
class WrongConstructor {}

@ShouldThrow('Default constructor for "NoDefaultConstructor" is missing.')
@CopyWith()
class NoDefaultConstructor {
  NoDefaultConstructor.nonDefault();
}
