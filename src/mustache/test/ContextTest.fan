class ContextTest : Test
{
  Void testNullContext()
  {
    verifyNull(MustacheToken.valueOf("testKey",null,[:],[,],"","{{","}}",""))
  }

  Void testMap()
  {
    verifyNull(MustacheToken.valueOf("n/a",[:],[:],[,],"","{{","}}",""))
    verifyEq(MustacheToken.valueOf("foo",["foo":"bar"],[:],[,],"","{{","}}",""),"bar")
  }

  Void testObject()
  {
    verifyNull(MustacheToken.valueOf("n/a",this,[:],[,],"","{{","}}",""))
    verifyEq(MustacheToken.format(MustacheToken.valueOf("sampleField",this,[:],[,],"","{{","}}","")),"foo")
    verifyEq(MustacheToken.format(MustacheToken.valueOf("sampleMethod",this,[:],[,],"","{{","}}","")),"bar")
  }

  Void testLambdaNoArgs() {
    verifyEq(MustacheToken.format(MustacheToken.valueOf("lambda",[
      "lambda": |->Str| { return "lambdaValue" }
    ],[:],[,],"","{{","}}","this text will be replaced")),"lambdaValue")
  }

  Void testLambdaChildText() {
    verifyEq(MustacheToken.format(MustacheToken.valueOf("lambda",[
      "lambda": |Str text->Str| { return "<b>$text</b>" }
    ],[:],[,],"","{{","}}","childrenText")),"<b>childrenText</b>")
  }

  Void testMethodChildText() {
    verifyEq(MustacheToken.format(MustacheToken.valueOf("sampleMethod1",this,[:],[,],"","{{","}}","childrenText")),"<b>childrenText</b>")
  }

  Void testTrap() {
    verifyEq(MustacheToken.format(MustacheToken.valueOf("trappedKey",this,[:],[,],"","{{","}}","")),"trappedValue")
  }

  const Str sampleField := "foo"
  Str sampleMethod() { return "bar" }
  Str sampleMethod1(Str text) { return "<b>$text</b>" }

  override Obj? trap(Str name, Obj?[]? args := null) {
    if (name == "trappedKey")
      return "trappedValue"
    else
      return null
  }
}
