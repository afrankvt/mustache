class LambdasTest : Test
{
  Void testIssue1()
  {
    //I want to do smth like:
    template := Mustache("{{#formatDate}}varName{{/formatDate}}".in)
   
    context := ["formatDate": |Str childrenSrc, |Str->Obj?| context, Func render -> Obj?| {
                              Date date := context(childrenSrc)
                              return date.toLocale("MMM DD, YYYY")
                            }
              ,"varName": Date.make(1925, Month.nov, 28) // the day Earth should have hit the heavenly axle
    ]
    verifyEq(template.render(context),"Nov 28, 1925")
  }

  Void testIssue1a()
  {
    //but I still want to do smth like:
    template := Mustache("{{#lambdaList}}{{.}} {{/lambdaList}}".in)
   
    context := ["lambdaList": |->Obj?| {
                              return [2, 10, 18, 36, 54, 86] // atomic magic numbers
                            }
    ]
    verifyEq(template.render(context),"2 10 18 36 54 86 ")
  }

  Void testIssue2()
  {
    template := Mustache("{{#formatDate}}varName{{/formatDate}}".in)
  
    // use |Str->Obj?| for context if you gonna resolve something in lambda 
    context1 := ["formatDate": |Str childrenSrc, |Str->Obj?| context, Func render -> Obj?| {
                              return false
                            }
      ,"foo": "bar"
    ]
    // use Obj? for context if you gonna transform the context value somehow
    context2 := ["formatDate": |Str childrenSrc, Obj? ctx, Func render -> Obj?| {
                              verifyEq(ctx.typeof, [Str:Obj]#)
                              return false
                            }
      ,"foo": "bar"
    ]
    verifyEq(template.render(context1),"")
    verifyEq(template.render(context2),"")
  }
}

