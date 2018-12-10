**
**  Partial tags are used to expand an external template into the current
**  template.
**
**  The tag's content MUST be a non-whitespace character sequence NOT containing
**  the current closing delimiter.
**
**  This tag's content names the partial to inject.  Set Delimiter tags MUST NOT
**  affect the parsing of a partial.  The partial MUST be rendered against the
**  context stack local to the tag.
**
**  Partial tags SHOULD be treated as standalone when appropriate.  If this tag
**  is used standalone, any whitespace preceding the tag should treated as
**  indentation, and prepended to each line of the partial before rendering.
**
class SpecsPartialsTest : Test
{
  ** The greater-than operator should expand to the named partial.
  Void testBasicBehavior() {
    verifyEq(
      Mustache(
        "\"{{>text}}\"".in
      ).render([:],["text": Mustache("from partial".in)])
      , "\"from partial\""
    )
  }

  ** The greater-than operator should operate within the current context.
  Void testContext() {
    verifyEq(
      Mustache(
        "\"{{>partial}}\"".in
      ).render(["text":"content"],["partial": Mustache("*{{text}}*".in)])
      , "\"*content*\""
    )
  }

  ** The greater-than operator should properly recurse.
  Void testRecursion() {
    verifyEq(
      Mustache(
        "{{>node}}".in
      ).render(
        ["content":"X", "nodes": [ 
            ["content": "Y", "nodes":[,]]
          ]
        ]
        ,["node": Mustache("{{content}}<{{#nodes}}{{>node}}{{/nodes}}>".in)]
      )
      , "X<Y<>>"
    )
  }

  ** The greater-than operator should not alter surrounding whitespace.
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "| {{>partial}} |".in
      ).render(
        [:]
        ,["partial": Mustache("\t|\t".in)]
      )
      , "| \t|\t |"
    )
  }

  ** Whitespace should be left untouched.
  Void testInlineIndentation() {
    verifyEq(
      Mustache(
        "  {{data}}  {{> partial}}\n".in
      ).render(
        ["data":"|"]
        ,["partial": Mustache(">\n>".in)]
      )
      , "  |  >\n>\n"
    )
  }

  ** "\r\n" should be considered a newline for standalone tags.
  Void testStandaloneLineEndings() {
    verifyEq(
      Mustache(
        "|\r\n{{>partial}}\r\n|".in
      ).render(
        [:]
        ,["partial": Mustache(">".in)]
      )
      , "|\r\n>|"
    )
  }

  ** Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutPreviousLine() {
    verifyEq(
      Mustache(
        "  {{>partial}}\n>".in
      ).render(
        [:]
        ,["partial": Mustache(">\n>".in)]
      )
      , "  >\n  >>"
    )
  }

  ** Standalone tags should not require a newline to follow them.
  Void testStandaloneWithoutNewline() {
    verifyEq(
      Mustache(
        ">\n  {{>partial}}".in
      ).render(
        [:]
        ,["partial": Mustache(">\n>".in)]
      )
      , ">\n  >\n  >"
    )
  }

  ** Each line of the partial should be indented before rendering.
  Void testStandaloneIndentation() {
    verifyEq(
      Mustache(
     "
      \\
       {{>partial}}
      /
      ".in
      ).render(
        ["content":"<\n->"]
        ,["partial": Mustache(
     "|
      {{{content}}}
      |
      ".in)
        ]
      )
      , 
     "
      \\
       |
       <
      ->
       |
      /
      "
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testPadding() {
    verifyEq(
      Mustache(
        "|{{> partial }}|".in
      ).render(
        ["boolean":true]
        ,["partial": Mustache("[]".in)]
      )
      , "|[]|"
    )
  }

}
