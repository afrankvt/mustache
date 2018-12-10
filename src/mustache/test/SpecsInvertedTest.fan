**
**  Inverted Section tags and End Section tags are used in combination to wrap a
**  section of the template.
**
**  These tags' content MUST be a non-whitespace character sequence NOT
**  containing the current closing delimiter; each Inverted Section tag MUST be
**  followed by an End Section tag with the same content within the same
**  section.
**
**  This tag's content names the data to replace the tag.  Name resolution is as
**  follows:
**    1) Split the name on periods; the first part is the name to resolve, any
**    remaining parts should be retained.
**    2) Walk the context stack from top to bottom, finding the first context
**    that is a) a hash containing the name as a key OR b) an object responding
**    to a method with the given name.
**    3) If the context is a hash, the data is the value associated with the
**    name.
**    4) If the context is an object and the method with the given name has an
**    arity of 1, the method SHOULD be called with a String containing the
**    unprocessed contents of the sections; the data is the value returned.
**    5) Otherwise, the data is the value returned by calling the method with
**    the given name.
**    6) If any name parts were retained in step 1, each should be resolved
**    against a context stack containing only the result from the former
**    resolution.  If any part fails resolution, the result should be considered
**    falsey, and should interpolate as the empty string.
**  If the data is not of a list type, it is coerced into a list as follows: if
**  the data is truthy (e.g. `!!data == true`), use a single-element list
**  containing the data, otherwise use an empty list.
**
**  This section MUST NOT be rendered unless the data list is empty.
**
**  Inverted Section and End Section tags SHOULD be treated as standalone when
**  appropriate.
**
class SpecsInvertedTest : Test
{
  ** Falsey sections should have their contents rendered.
  Void testFalsey() {
    verifyEq(
      Mustache(
        "\"{{^boolean}}This should be rendered.{{/boolean}}\"".in
      ).render(["boolean": false])
      , "\"This should be rendered.\""
    )
  }

  ** Truthy sections should have their contents omitted.
  Void testTruthy() {
    verifyEq(
      Mustache(
        "\"{{^boolean}}This should not be rendered.{{/boolean}}\"".in
      ).render(["boolean": true])
      , "\"\""
    )
  }

  ** Objects and hashes should behave like truthy values.
  Void testContext() {
    verifyEq(
      Mustache(
        "\"{{^context}}Hi {{name}}.{{/context}}\"".in
      ).render(["context": ["name" : "Joe"]])
      , "\"\""
    )
  }

  ** Lists should behave like truthy values.
  Void testList() {
    verifyEq(
      Mustache(
        "\"{{^list}}{{n}}{{/list}}\"".in
      ).render(["list": [ ["n": 1], ["n": 2], ["n": 3] ]])
      , "\"\""
    )
  }

  ** Empty lists should behave like falsey values.
  Void testEmptyList() {
    verifyEq(
      Mustache(
        "\"{{^list}}Yay lists!{{/list}}\"".in
      ).render(["list": [,]])
      , "\"Yay lists!\""
    )
  }

  ** Multiple inverted sections per template should be permitted.
  Void testDoubled() {
    verifyEq(
      Mustache(
     "
      {{^bool}}
      * first
      {{/bool}}
      * {{two}}
      {{^bool}}
      * third
      {{/bool}}
      ".in
      ).render(["bool": false, "two": "second"])
      ,
     "
      * first
      * second
      * third
      "
    )
  }

  ** Nested falsey sections should have their contents rendered.
  Void testNestedFalsey() {
    verifyEq(
      Mustache(
        "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |".in
      ).render(["bool": false])
      , "| A B C D E |"
    )
  }

  ** Nested truthy sections should be omitted.
  Void testNestedTruthy() {
    verifyEq(
      Mustache(
        "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |".in
      ).render(["bool": true])
      , "| A  E |"
    )
  }

  ** Failed context lookups should be considered falsey.
  Void testContextMisses() {
    verifyEq(
      Mustache(
        "[{{^missing}}Cannot find key 'missing'!{{/missing}}]".in
      ).render([:])
      , "[Cannot find key 'missing'!]"
    )
  }

  ** Dotted names should be valid for Inverted Section tags.
  Void testDottedNamesTruthy() {
    verifyEq(
      Mustache(
        "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"\"".in
      ).render(["a":["b":["c":true]]])
      , "\"\" == \"\""
    )
  }

  ** Dotted names should be valid for Inverted Section tags.
  Void testDottedNamesFalsey() {
    verifyEq(
      Mustache(
        "\"{{^a.b.c}}Not Here{{/a.b.c}}\" == \"Not Here\"".in
      ).render(["a":["b":["c":false]]])
      , "\"Not Here\" == \"Not Here\""
    )
  }

  ** Inverted sections should not alter surrounding whitespace.
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        " | {{^boolean}}\t|\t{{/boolean}} | \n".in
      ).render(["boolean":false])
      , " | \t|\t | \n"
    )
  }

  ** Inverted should not alter internal whitespace.
  Void testInternalWhitespace() {
    verifyEq(
      Mustache(
        " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n".in
      ).render(["boolean":false])
      , " |  \n  | \n"
    )
  }
  
  ** Single-line sections should not alter surrounding whitespace.
  Void testIdentedInlineSections() {
    verifyEq(
      Mustache(
        " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n".in
      ).render(["boolean":false])
      , " NO\n WAY\n"
    )
  }
  
  ** Standalone lines should be removed from the template.
  Void testStandaloneLines() {
    verifyEq(
      Mustache(
     "
      | This Is
      {{^boolean}}
      |
      {{/boolean}}
      | A Line
      ".in
      ).render(["boolean":false])
      ,
     "
      | This Is
      |
      | A Line
      "
    )
  }

  ** Standalone lines should be removed from the template.
  Void testStandaloneIndentedLines() {
    verifyEq(
      Mustache(
     "
      | This Is
        {{^boolean}}
      |
        {{/boolean}}
      | A Line
      ".in
      ).render(["boolean":false])
      ,
     "
      | This Is
      |
      | A Line
      "
    )
  }

  ** '"\r\n" should be considered a newline for standalone tags.
  Void testStandaloneLineEndings() {
    verifyEq(
      Mustache(
        "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|".in
      ).render(["boolean":false])
      ,"|\r\n|"
    )
  }

  ** Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutPreviousLine() {
    verifyEq(
      Mustache(
        "  {{^boolean}}\n^{{/boolean}}\n/".in
      ).render(["boolean":false])
      ,"^\n/"
    )
  }

  ** Standalone tags should not require a newline to follow them.
  Void testStandaloneWithoutNewline() {
    verifyEq(
      Mustache(
        "^{{^boolean}}\n/\n  {{/boolean}}".in
      ).render(["boolean":false])
      ,"^\n/\n"
    )
  }

  ** Standalone tags should not require a newline to follow them.
  Void testPadding() {
    verifyEq(
      Mustache(
        "|{{^ boolean }}={{/ boolean }}|".in
      ).render(["boolean":false])
      ,"|=|"
    )
  }

}
