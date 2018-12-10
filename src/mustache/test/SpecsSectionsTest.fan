** 
**  Section tags and End Section tags are used in combination to wrap a section
**  of the template for iteration
**
**  These tags' content MUST be a non-whitespace character sequence NOT
**  containing the current closing delimiter; each Section tag MUST be followed
**  by an End Section tag with the same content within the same section.
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
**  For each element in the data list, the element MUST be pushed onto the
**  context stack, the section MUST be rendered, and the element MUST be popped
**  off the context stack.
**
**  Section and End Section tags SHOULD be treated as standalone when
**  appropriate.
**
class SpecsSectionsTest : Test
{
  ** Truthy sections should have their contents rendered.
  Void testTruthy() {
    verifyEq(
      Mustache(
        "\"{{#boolean}}This should be rendered.{{/boolean}}\"".in
      ).render(["boolean": true])
      , "\"This should be rendered.\""
    )
  }

  ** Falsey sections should have their contents omitted.
  Void testFalsey() {
    verifyEq(
      Mustache(
        "\"{{#boolean}}This should not be rendered.{{/boolean}}\"".in
      ).render(["boolean": false])
      , "\"\""
    )
  }

  ** Objects and hashes should behave like truthy values.
  Void testContext() {
    verifyEq(
      Mustache(
        "\"{{#context}}Hi {{name}}.{{/context}}\"".in
      ).render(["context": ["name" : "Joe"]])
      , "\"Hi Joe.\""
    )
  }

  ** All elements on the context stack should be accessible.
  Void testDeeplyNestedContexts() {
    verifyEq(
      Mustache(
     "
      {{#a}}
      {{one}}
      {{#b}}
      {{one}}{{two}}{{one}}
      {{#c}}
      {{one}}{{two}}{{three}}{{two}}{{one}}
      {{#d}}
      {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
      {{#e}}
      {{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
      {{/e}}
      {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
      {{/d}}
      {{one}}{{two}}{{three}}{{two}}{{one}}
      {{/c}}
      {{one}}{{two}}{{one}}
      {{/b}}
      {{one}}
      {{/a}}
      ".in
      ).render([
        "a": [ "one": 1 ]
        ,"b": [ "two": 2 ]
        ,"c": [ "three": 3 ]
        ,"d": [ "four": 4 ]
        ,"e": [ "five": 5 ]
      ])
      ,
     "
      1
      121
      12321
      1234321
      123454321
      1234321
      12321
      121
      1
      "
    )
  }

  ** Lists should be iterated; list items should visit the context stack.
  Void testList() {
    verifyEq(
      Mustache(
        "\"{{#list}}{{item}}{{/list}}\"".in
      ).render([
        "list": [ ["item":1],["item":2],["item":3] ]
      ])
      , "\"123\""
    )
  }

  ** Empty lists should behave like falsey values.
  Void testEmptyList() {
    verifyEq(
      Mustache(
        "\"{{#list}}Yay lists!{{/list}}\"".in
      ).render([
        "list": [,]
      ])
      , "\"\""
    )
  }
  
  ** Multiple sections per template should be permitted.
  Void testDoubled() {
    verifyEq(
      Mustache(
     "
      {{#bool}}
      * first
      {{/bool}}
      * {{two}}
      {{#bool}}
      * third
      {{/bool}}
      ".in
      ).render([
        "bool": true, "two": "second"
      ])
      , 
     "
      * first
      * second
      * third
      "
    )
  }

  ** Nested truthy sections should have their contents rendered.
  Void testNestedTruthy() {
    verifyEq(
      Mustache(
        "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |".in
      ).render(["bool": true])
      , "| A B C D E |"
    )
  }

  ** Nested falsey sections should be omitted.
  Void testNestedFalsey() {
    verifyEq(
      Mustache(
        "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |".in
      ).render(["bool": false])
      , "| A  E |"
    )
  }

  ** Failed context lookups should be considered falsey.
  Void testContextMisses() {
    verifyEq(
      Mustache(
        "[{{#missing}}Found key 'missing'!{{/missing}}]".in
      ).render([:])
      , "[]"
    )
  }

  ** Implicit iterators should directly interpolate strings.
  Void testImplicitIterator() {
    verifyEq(
      Mustache(
        "\"{{#list}}({{.}}){{/list}}\"".in
      ).render(["list":["a","b","c","d","e"]])
      , "\"(a)(b)(c)(d)(e)\""
    )
  }

  ** Implicit iterators should cast integers to strings and interpolate.
  Void testImplicitIteratorInteger() {
    verifyEq(
      Mustache(
        "\"{{#list}}({{.}}){{/list}}\"".in
      ).render(["list":[1,2,3,4,5]])
      , "\"(1)(2)(3)(4)(5)\""
    )
  }

  ** Implicit iterators should cast decimals to strings and interpolate.
  Void testImplicitIteratorDecimal() {
    verifyEq(
      Mustache(
        "\"{{#list}}({{.}}){{/list}}\"".in
      ).render(["list":[1.10d, 2.20d, 3.30d, 4.40d, 5.50d]])
      , "\"(1.1)(2.2)(3.3)(4.4)(5.5)\""
    )
  }

  ** Dotted names should be valid for Section tags.
  Void testDottedNamesTruthy() {
    verifyEq(
      Mustache(
        "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"Here\"".in
      ).render(["a":["b":["c":true]]])
      , "\"Here\" == \"Here\""
    )
  }

  ** Dotted names should be valid for Section tags.
  Void testDottedNamesFalsey() {
    verifyEq(
      Mustache(
        "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\"".in
      ).render(["a":["b":["c":false]]])
      , "\"\" == \"\""
    )
  }

  ** Dotted names that cannot be resolved should be considered falsey.
  Void testDottedNamesBrokenChains() {
    verifyEq(
      Mustache(
        "\"{{#a.b.c}}Here{{/a.b.c}}\" == \"\"".in
      ).render(["a":[:]])
      , "\"\" == \"\""
    )
  }

  ** Sections should not alter surrounding whitespace.
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        " | {{#boolean}}\t|\t{{/boolean}} | \n".in
      ).render(["boolean": true])
      , " | \t|\t | \n"
    )
  }

  ** Sections should not alter internal whitespace.
  Void testInternalWhitespace() {
    verifyEq(
      Mustache(
        " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n".in
      ).render(["boolean": true])
      , " |  \n  | \n"
    )
  }

  ** Single-line sections should not alter surrounding whitespace.
  Void testIndentedInlineWhitespace() {
    verifyEq(
      Mustache(
        " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n".in
      ).render(["boolean": true])
      , " YES\n GOOD\n"
    )
  }

  ** Standalone lines should be removed from the template.
  Void testStandalone() {
    verifyEq(
      Mustache(
     "
      | This Is
      {{#boolean}}
      |
      {{/boolean}}
      | A Line
      ".in
      ).render(["boolean": true])
      ,
     "
      | This Is
      |
      | A Line
      "
    )
  }

  ** Indented standalone lines should be removed from the template.
  Void testIndentedStandalone() {
    verifyEq(
      Mustache(
     "
      | This Is
        {{#boolean}}
      |
        {{/boolean}}
      | A Line
      ".in
      ).render(["boolean": true])
      ,
     "
      | This Is
      |
      | A Line
      "
    )
  }

  ** "\r\n" should be considered a newline for standalone tags.
  Void testStandaloneLineEndings() {
    verifyEq(
      Mustache(
        "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|".in
      ).render(["boolean": true])
      , "|\r\n|"
    )
  }

  **  Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutPreviousLine() {
    verifyEq(
      Mustache(
        "  {{#boolean}}\n#{{/boolean}}\n/".in
      ).render(["boolean": true])
      , "#\n/"
    )
  }

  **  Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutNewline() {
    verifyEq(
      Mustache(
        "#{{#boolean}}\n/\n  {{/boolean}}".in
      ).render(["boolean": true])
      , "#\n/\n"
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testPadding() {
    verifyEq(
      Mustache(
        "|{{# boolean }}={{/ boolean }}|".in
      ).render(["boolean": true])
      , "|=|"
    )
  }


}

