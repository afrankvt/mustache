**
**   Comment tags represent content that should never appear in the resulting
**  output.
**
**  The tag's content may contain any substring (including newlines) EXCEPT the
**  closing delimiter.
**
**  Comment tags SHOULD be treated as standalone when appropriate.
**
class SpecsCommentsTest : Test
{

  ** Comment blocks should be removed from the template.
  Void testInline() {
    verifyEq(
      Mustache(
        "12345{{! Comment Block! }}67890".in
      ).render(null)
      ,"1234567890"
    )

    verifyEq(
      Mustache("text{{! [a1,a2,a3,{},year,month,day,ruleId] }}\n  ...".in).render(null),
      "text\n  ..."
    )
  }

  ** Multiline comments should be permitted.
  Void testMultiline() {
    verifyEq(
      Mustache(
        "12345{{!\nThis is a\nmulti-line comment...\n}}67890".in
      ).render(null)
      ,"1234567890"
    )
  }

  ** All standalone comment lines should be removed.
  Void testStandalone() {
    verifyEq(
      Mustache(
        "Begin.\n{{! Comment Block! }}\nEnd.".in
      ).render(null)
      ,"Begin.\nEnd."
    )
  }

  ** All standalone comment lines should be removed.
  Void testIndentedStandalone() {
    verifyEq(
      Mustache(
        "Begin.\n  {{! Indented Comment Block! }}\nEnd.".in
      ).render(null)
      ,"Begin.\nEnd."
    )
  }

  ** "\r\n" should be considered a newline for standalone tags.
  Void testStandaloneLineEndings() {
    verifyEq(
      Mustache(
        "|\r\n{{! Standalone Comment }}\r\n|".in
      ).render(null)
      ,"|\r\n|"
    )
  }

  ** Standalone tags should not require a newline to precede them.
  Void testStandaloneWithoutPreviousLine() {
    verifyEq(
      Mustache(
        "  {{! I'm Still Standalone }}\n!".in
      ).render(null)
      ,"!"
    )
  }

  ** Standalone tags should not require a newline to follow them.
  Void testStandaloneWithoutNewline() {
    verifyEq(
      Mustache(
        "!\n  {{! I'm Still Standalone }}".in
      ).render(null)
      ,"!\n"
    )
  }

  ** All standalone comment lines should be removed.
  Void testMultilineStandalone() {
    verifyEq(
      Mustache(
        "Begin.\n{{!\n  Something's going on here...\n}}\nEnd.".in
      ).render(null)
      ,"Begin.\nEnd."
    )
  }

  ** All standalone comment lines should be removed.
  Void testIndentedMultilineStandalone() {
    verifyEq(
      Mustache(
        "Begin.\n  {{!\n    Something's going on here...\n  }}\nEnd.".in
      ).render(null)
      ,"Begin.\nEnd."
    )
  }

  ** Inline comments should not strip whitespace
  Void testIndentedInline() {
    verifyEq(
      Mustache(
        "  12 {{! 34 }}\n".in
      ).render(null)
      ,"  12 \n"
    )
  }

  ** Comment removal should preserve surrounding whitespace.
  Void testSurroundingWhitespace() {
    verifyEq(
      Mustache(
        "12345 {{! Comment Block! }} 67890".in
      ).render(null)
      ,"12345  67890"
    )
  }

}
