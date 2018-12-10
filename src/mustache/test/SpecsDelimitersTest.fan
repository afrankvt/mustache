**
**  Set Delimiter tags are used to change the tag delimiters for all content
**  following the tag in the current compilation unit.
**
**  The tag's content MUST be any two non-whitespace sequences (separated by
**  whitespace) EXCEPT an equals sign ('=') followed by the current closing
**  delimiter.
**
**  Set Delimiter tags SHOULD be treated as standalone when appropriate.
**
class SpecsDelimitersTest : Test
{

  ** The equals sign (used on both sides) should permit delimiter changes.
  Void testPairBehavior() {
    verifyEq(
      Mustache(
        "{{=<% %>=}}(<%text%>)".in
      ).render(["text":"Hey!"])
      ,"(Hey!)"
    )
  }

  ** Characters with special meaning regexen should be valid delimiters.
  Void testSpecialCharacters() {
    verifyEq(
      Mustache(
        "({{=[ ]=}}[text])".in
      ).render(["text":"It worked!"])
      ,"(It worked!)"
    )
  }

  ** Delimiters set outside sections should persist.
  Void testSections() {
    verifyEq(
      Mustache(
     "[
      {{#section}}
        {{data}}
        |data|
      {{/section}}

      {{= | | =}}
      |#section|
        {{data}}
        |data|
      |/section|
      ]".in
      ).render(["section":true, "data": "I got interpolated."])
      ,
     "[
        I got interpolated.
        |data|

        {{data}}
        I got interpolated.
      ]"
    )
  }

  ** Delimiters set outside inverted sections should persist.
  Void testInvertedSections() {
    verifyEq(
      Mustache(
     "[
      {{^section}}
        {{data}}
        |data|
      {{/section}}

      {{= | | =}}
      |^section|
        {{data}}
        |data|
      |/section|
      ]".in
      ).render(["section":false, "data": "I got interpolated."])
      ,
     "[
        I got interpolated.
        |data|

        {{data}}
        I got interpolated.
      ]"
    )
  }

  ** Delimiters set in a parent template should not affect a partial.
  Void testPartialInheritence() {
    verifyEq(
      Mustache(
     "
      [ {{>include}} ]
      {{= | | =}}
      [ |>include| ]
      ".in
      ).render(["value":"yes"], ["include": Mustache(".{{value}}.".in)])
      ,
     "
      [ .yes. ]
      [ .yes. ]
      "
    )
  }

  ** Delimiters set in a partial should not affect the parent template.
  Void testPostPartialBehavior() {
    verifyEq(
      Mustache(
     "
      [ {{>include}} ]
      [ .{{value}}.  .|value|. ]
      ".in
      ).render(["value":"yes"], ["include": Mustache(".{{value}}. {{= | | =}} .|value|.".in)])
      ,
     "
      [ .yes.  .yes. ]
      [ .yes.  .|value|. ]
      "
    )
  }

  ** Surrounding whitespace should be left untouched
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "| {{=@ @=}} |".in
      ).render(null)
      , "|  |"
    )
  }

  ** Whitespace should be left untouched
  Void testOutlyingWhitespace() {
    verifyEq(
      Mustache(
        " | {{=@ @=}}\n".in
      ).render(null)
      , " | \n"
    )
  }

  ** Standalone lines should be removed from the template.
  Void testStandaloneTag() {
    verifyEq(
      Mustache(
     "
      Begin.
      {{=@ @=}}
      End.
      ".in
      ).render(null)
      ,
     "
      Begin.
      End.
      "
    )
  }

  ** Indented standalone lines should be removed from the template.
  Void testIndentedStandaloneTag() {
    verifyEq(
      Mustache(
     "
      Begin.
        {{=@ @=}}
      End.
      ".in
      ).render(null)
      ,
     "
      Begin.
      End.
      "
    )
  }

  ** '"\r\n" should be considered a newline for standalone tags.'
  Void testStandaloneLineEndings() {
    verifyEq(
      Mustache(
        "|\r\n{{= @ @ =}}\r\n|".in
      ).render(null)
      , "|\r\n|"
    )
  }

  ** Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutPreviousLine() {
    verifyEq(
      Mustache(
        "  {{=@ @=}}\n=".in
      ).render(null)
      , "="
    )
  }

  ** Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutNewline() {
    verifyEq(
      Mustache(
        "=\n  {{=@ @=}}".in
      ).render(null)
      , "=\n"
    )
  }

  ** Superfluous in-tag whitespace should be ignored.
  Void testPairWithPadding() {
    verifyEq(
      Mustache(
        "|{{= @   @ =}}|".in
      ).render(null)
      , "||"
    )
  }

}
