class EscapeTest : Test
{
  Void testEscapedAndUnescapedTokens()
  {
    etoken := EscapedToken("foo","{{","}}", false)
    utoken := UnescapedToken("foo","{{","}}", false)

    verifyEq(etoken.templateSource(), "{{foo}}")
    verifyEq(utoken.templateSource(), "{{{foo}}}")

    ctx := ["foo":"<\">&test"]

    ebuf := StrBuf()
    ubuf := StrBuf()

    etoken.render(ebuf,ctx,[:],[,],"")
    utoken.render(ubuf,ctx,[:],[,],"")

    verifyEq(ebuf.toStr, "&lt;&quot;&gt;&amp;test")
    verifyEq(ubuf.toStr, "<\">&test")
  }
}
