**
**  Interpolation tags are used to integrate dynamic content into the template.
**
**  The tag's content MUST be a non-whitespace character sequence NOT containing
**  the current closing delimiter.
**
**  This tag's content names the data to replace the tag.  A single period (`.`)
**  indicates that the item currently sitting atop the context stack should be
**  used; otherwise, name resolution is as follows:
**    1) Split the name on periods; the first part is the name to resolve, any
**    remaining parts should be retained.
**    2) Walk the context stack from top to bottom, finding the first context
**    that is a) a hash containing the name as a key OR b) an object responding
**    to a method with the given name.
**    3) If the context is a hash, the data is the value associated with the
**    name.
**    4) If the context is an object, the data is the value returned by the
**    method with the given name.
**    5) If any name parts were retained in step 1, each should be resolved
**    against a context stack containing only the result from the former
**    resolution.  If any part fails resolution, the result should be considered
**    falsey, and should interpolate as the empty string.
**  Data should be coerced into a string (and escaped, if appropriate) before
**  interpolation.
**
**  The Interpolation tags MUST NOT be treated as standalone.
**
class SpecsInterpolationTest : Test
{
  ** Mustache-free templates should render as-is.
  Void testNoInterpolation() {
    verifyEq(
      Mustache(
        "Hello from {Mustache}!".in
      ).render(null)
      , "Hello from {Mustache}!"
    )
  }

  ** Unadorned tags should interpolate content into the template.
  Void testBasicInterpolation() {
    verifyEq(
      Mustache(
        "Hello, {{subject}}!".in
      ).render(["subject": "world"])
      , "Hello, world!"
    )
  }

  ** Basic interpolation should be HTML escaped.
  Void testHTMLEscaping() {
    verifyEq(
      Mustache(
        "These characters should be HTML escaped: {{forbidden}}".in
      ).render(["forbidden": "& \" < >"])
      , "These characters should be HTML escaped: &amp; &quot; &lt; &gt;"
    )
  }
  
  ** Triple mustaches should interpolate without HTML escaping.
  Void testTripleMustache() {
    verifyEq(
      Mustache(
        "These characters should not be HTML escaped: {{{forbidden}}}".in
      ).render(["forbidden": "& \" < >"])
      , "These characters should not be HTML escaped: & \" < >"
    )
  }

  ** Ampersand should interpolate without HTML escaping.
  Void testAmpersand() {
    verifyEq(
      Mustache(
        "These characters should not be HTML escaped: {{&forbidden}}".in
      ).render(["forbidden": "& \" < >"])
      , "These characters should not be HTML escaped: & \" < >"
    )
  }

  ** Integers should interpolate seamlessly.
  Void testBasicIntegerInterpolation() {
    verifyEq(
      Mustache(
        "\"{{mph}} miles an hour!\"".in
      ).render(["mph": 85])
      , "\"85 miles an hour!\""
    )
  }

  ** Integers should interpolate seamlessly.
  Void testTripleMustacheIntegerInterpolation() {
    verifyEq(
      Mustache(
        "\"{{{mph}}} miles an hour!\"".in
      ).render(["mph": 85])
      , "\"85 miles an hour!\""
    )
  }

  ** Integers should interpolate seamlessly.
  Void testAmpersandIntegerInterpolation() {
    verifyEq(
      Mustache(
        "\"{{&mph}} miles an hour!\"".in
      ).render(["mph": 85])
      , "\"85 miles an hour!\""
    )
  }

  ** Decimals should interpolate seamlessly with proper significance.
  Void testBasicDecimalInterpolation() {
    verifyEq(
      Mustache(
        "\"{{power}} jiggawatts!\"".in
      ).render(["power": 1.210d])
      , "\"1.21 jiggawatts!\""
    )
  }

  ** Decimals should interpolate seamlessly with proper significance.
  Void testTripleMustacheDecimalInterpolation() {
    verifyEq(
      Mustache(
        "\"{{{power}}} jiggawatts!\"".in
      ).render(["power": 1.210d])
      , "\"1.21 jiggawatts!\""
    )
  }

  ** Decimals should interpolate seamlessly with proper significance.
  Void testAmpersandDecimalInterpolation() {
    verifyEq(
      Mustache(
        "\"{{&power}} jiggawatts!\"".in
      ).render(["power": 1.210d])
      , "\"1.21 jiggawatts!\""
    )
  }

  ** Failed context lookups should default to empty strings.
  Void testBasicContentMissInterpolation() {
    verifyEq(
      Mustache(
        "I ({{cannot}}) be seen!".in
      ).render([:])
      , "I () be seen!"
    )
  }

  ** Failed context lookups should default to empty strings.
  Void testTripleMustacheContentMissInterpolation() {
    verifyEq(
      Mustache(
        "I ({{{cannot}}}) be seen!".in
      ).render([:])
      , "I () be seen!"
    )
  }

  ** Failed context lookups should default to empty strings.
  Void testAmpersandContentMissInterpolation() {
    verifyEq(
      Mustache(
        "I ({{&cannot}}) be seen!".in
      ).render([:])
      , "I () be seen!"
    )
  }

  ** Dotted names should be considered a form of shorthand for sections.
  Void testBasicDottedNames() {
    verifyEq(
      Mustache(
        "\"{{person.name}}\" == \"{{#person}}{{name}}{{/person}}\"".in
      ).render(["person":["name": "Joe"]])
      , "\"Joe\" == \"Joe\""
    )
  }

  ** Dotted names should be considered a form of shorthand for sections.
  Void testTripleMustacheDottedNames() {
    verifyEq(
      Mustache(
        "\"{{{person.name}}}\" == \"{{#person}}{{{name}}}{{/person}}\"".in
      ).render(["person":["name": "Joe"]])
      , "\"Joe\" == \"Joe\""
    )
  }

  ** Dotted names should be considered a form of shorthand for sections.
  Void testAmpersandDottedNames() {
    verifyEq(
      Mustache(
        "\"{{&person.name}}\" == \"{{#person}}{{&name}}{{/person}}\"".in
      ).render(["person":["name": "Joe"]])
      , "\"Joe\" == \"Joe\""
    )
  }

  ** Dotted names should be functional to any level of nesting.
  Void testArbitaryDepthDottedNames() {
    verifyEq(
      Mustache(
        "\"{{a.b.c.d.e.name}}\" == \"Phil\"".in
      ).render(["a":["b":["c":["d":["e":["name":"Phil"]]]]]])
      , "\"Phil\" == \"Phil\""
    )
  }

  ** Any falsey value prior to the last part of the name should yield ''.
  Void testBrokenChainsDottedNames() {
    verifyEq(
      Mustache(
        "\"{{a.b.c}}\" == \"\"".in
      ).render(["a":[:]])
      , "\"\" == \"\""
    )
  }

  ** Each part of a dotted name should resolve only against its parent.
  Void testBrokenChainResolutionDottedNames() {
    verifyEq(
      Mustache(
        "\"{{a.b.c.name}}\" == \"\"".in
      ).render(["a":["b":[:]], "c":["name":"Jim"]])
      , "\"\" == \"\""
    )
  }

  ** The first part of a dotted name should resolve as any other name.
  Void testInitialResolutionDottedNames() {
    verifyEq(
      Mustache(
        "\"{{#a}}{{b.c.d.e.name}}{{/a}}\" == \"Phil\"".in
      ).render([
        "a":["b":["c":["d":["e":["name": "Phil"]]]]]
        ,"b":["c":["d":["e":["name":"Wrong"]]]]
      ])
      , "\"Phil\" == \"Phil\""
    )
  }

  ** Interpolation should not alter surrounding whitespace.
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "| {{string}} |".in
      ).render(["string":"---"])
      , "| --- |"
    )
  }

  ** Interpolation should not alter surrounding whitespace.
  Void testTripleMustacheSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "| {{{string}}} |".in
      ).render(["string":"---"])
      , "| --- |"
    )
  }

  ** Interpolation should not alter surrounding whitespace.
  Void testAmpersandSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "| {{&string}} |".in
      ).render(["string":"---"])
      , "| --- |"
    )
  }

  ** Standalone interpolation should not alter surrounding whitespace.
  Void testStandaloneSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "  {{string}}\n".in
      ).render(["string":"---"])
      , "  ---\n"
    )
  }

  ** Standalone interpolation should not alter surrounding whitespace.
  Void testTripleMustacheStandaloneSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "  {{{string}}}\n".in
      ).render(["string":"---"])
      , "  ---\n"
    )
  }

  ** Standalone interpolation should not alter surrounding whitespace.
  Void testAmpersandStandaloneSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "  {{&string}}\n".in
      ).render(["string":"---"])
      , "  ---\n"
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testInterpolationWithPadding() {
    verifyEq(
      Mustache(
        "|{{ string }}|".in
      ).render(["string":"---"])
      , "|---|"
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testTripleMustacheInterpolationWithPadding() {
    verifyEq(
      Mustache(
        "|{{{ string }}}|".in
      ).render(["string":"---"])
      , "|---|"
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testAmpersandInterpolationWithPadding() {
    verifyEq(
      Mustache(
        "|{{& string }}|".in
      ).render(["string":"---"])
      , "|---|"
    )
  }

}
