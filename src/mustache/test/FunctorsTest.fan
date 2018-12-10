class FunctorsTest : Test
{
  Void testFunctors()
  {
    template := Mustache("{{test}}".in)
    
    verifyEq(template.render(
      ["test": |->Obj?| {
                return |->Int| {
                  return 42
                }
              }
      ])
    , "42")
  }
}

