part of 'source_gen_tests.dart';

@ShouldThrow(
  'Only classes can be annotated with "CopyWith". "Object wrongAnnotation" is not a ClassElement.',
)
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
@CopyWith(namedConstructor: "test")
class WrongConstructor {}

@ShouldThrow('Default constructor for "NoDefaultConstructor" is missing.')
@CopyWith()
class NoDefaultConstructor {
  NoDefaultConstructor.nonDefault();
}

@ShouldThrow(
  'Unnamed constructor for "ConstructorWithSomeUnnamedFields" contains unnamed parameter "value". Constructors annotated with "CopyWith" can contain only named parameters.',
)
@CopyWith()
class ConstructorWithSomeUnnamedFields {
  int? test;
  int value;

  ConstructorWithSomeUnnamedFields(this.value, {this.test});
}

@ShouldThrow(
  'Unnamed constructor for "ConstructorWithAllUnnamedFields" contains unnamed parameter "value". Constructors annotated with "CopyWith" can contain only named parameters.',
)
@CopyWith()
class ConstructorWithAllUnnamedFields {
  int? test;
  int value;

  ConstructorWithAllUnnamedFields(this.value, this.test);
}

@ShouldThrow(
  'Constructor "test" for "NamedConstructorWithSomeUnnamedFields" contains unnamed parameter "value". Constructors annotated with "CopyWith" can contain only named parameters.',
)
@CopyWith(namedConstructor: "test")
class NamedConstructorWithSomeUnnamedFields {
  int? test;
  int value;

  NamedConstructorWithSomeUnnamedFields.test(this.value, this.test);
}
