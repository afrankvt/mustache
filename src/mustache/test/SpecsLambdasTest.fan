**
**  Lambdas are a special-cased data type for use in interpolations and
**  sections.
**
**  When used as the data value for an Interpolation tag, the lambda MUST be
**  treatable as an arity 0 function, and invoked as such.  The returned value
**  MUST be rendered against the default delimiters, then interpolated in place
**  of the lambda.
**
**  When used as the data value for a Section tag, the lambda MUST be treatable
**  as an arity 1 function, and invoked as such (passing a String containing the
**  unprocessed section contents).  The returned value MUST be rendered against
**  the current delimiters, then interpolated in place of the section.
**
class SpecsLambdasTest : Test
{
  ** A lambda's return value should be interpolated.
  Void testInterpolation() {
    verifyEq(
      Mustache(
        "Hello, {{lambda}}!".in
      ).render(["lambda": |->Str|{ "world" }])
      , "Hello, world!"
    )
  }

  ** A lambda's return value should be parsed.
  Void testInterpolationExpansion() {
    verifyEq(
      Mustache(
        "Hello, {{lambda}}!".in
      ).render(["planet":"world", "lambda": |->Str|{ "{{planet}}" }])
      , "Hello, world!"
    )
  }

  ** A lambda's return value should parse with the default delimiters.
  Void testInterpolationAlternateDelimiters() {
    verifyEq(
      Mustache(
        "{{= | | =}}\nHello, (|&lambda|)!".in
      ).render(["planet":"world", "lambda": |->Str|{ "|planet| => {{planet}}" }])
      , "Hello, (|planet| => world)!"
    )
  }

  ** Interpolated lambdas should not be cached.
  Void testInterpolationMultipleCalls() {
    calls := 0
    verifyEq(
      Mustache(
        "{{lambda}} == {{{lambda}}} == {{lambda}}".in
      ).render(["lambda": |->Int|{ ++calls }])
      , "1 == 2 == 3"
    )
  }

  ** Lambda results should be appropriately escaped.
  Void testEscaping() {
    calls := 0
    verifyEq(
      Mustache(
        "<{{lambda}}{{{lambda}}}".in
      ).render(["lambda": |->Str|{">"}])
      , "<&gt;>"
    )
  }

  ** Lambdas used for sections should receive the raw section string.
  Void testSection() {
    verifyEq(
      Mustache(
        "<{{#lambda}}{{x}}{{/lambda}}>".in
      ).render(["x":"Error!","lambda": |Str text->Str|{ return (text == "{{x}}")?"yes":"no" }])
      , "<yes>"
    )
  }

  ** Lambdas used for sections should have their results parsed.
  Void testSectionExpansion() {
    verifyEq(
      Mustache(
        "<{{#lambda}}-{{/lambda}}>".in
      ).render(["planet":"Earth", "lambda": |Str text->Str|{ return "$text{{planet}}$text" }])
      , "<-Earth->"
    )
  }

  ** Lambdas used for sections should parse with the current delimiters.
  Void testSectionsAlternateDelimiters() {
    verifyEq(
      Mustache(
        "{{= | | =}}<|#lambda|-|/lambda|>".in
      ).render(["planet":"Earth","lambda": |Str text->Str|{ return "$text{{planet}} => |planet|$text" }])
      , "<-{{planet}} => Earth->"
    )
  }

  ** Lambdas used for sections should not be cached.
  Void testSectionsMultipleCalls() {
    verifyEq(
      Mustache(
        "{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}".in
      ).render(["lambda": |Str text->Str|{ return "__${text}__" }])
      , "__FILE__ != __LINE__"
    )
  }

  ** Lambdas used for inverted sections should be considered truthy.
  Void testInvertedSections() {
    verifyEq(
      Mustache(
        "<{{^lambda}}{{static}}{{/lambda}}>".in
      ).render(["static":"static","lambda": |->Bool|{ false }])
      , "<>"
    )
  }


}
