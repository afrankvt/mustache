const mixin GravatarHelper {

  Str md5(Str src) {
    return src.toBuf.toDigest("MD5").toHex
  }

  Str gravatar(Str text, Obj? context, |Str->Str| render) {
    if (context is [Str:Obj]) {
      m := context as [Str:Obj]
      return gravatarForId(md5(m["email"].toStr.trim.lower))
    } else 
      throw ArgErr("Invalid context for gravatar helper: "+context)
  }

  Str gravatarForId(Str gid, Int size := 30) {
      gravatarHost + "/avatar/"+gid+"?s="+size
  }

  Str gravatarHost() {
    return ssl?"https://secure.gravatar.com":"http://www.gravatar.com"
  }

  abstract Bool ssl()
}

const class GravatarMustache : Mustache, GravatarHelper {
  private const Bool isSSL

  new make(Bool ssl, InStream in) : super(in) {
    this.isSSL = ssl
  }

  override Bool ssl() { return isSSL }
}

class CanonicalHelperTest : Test {

  Void testHelper()
  {
    result := GravatarMustache(
      true
      ,("<ul>" +
        "{{# users}}" +
          "<li><img src=\"{{ gravatar }}\">{{ login }}</li>" +
        "{{/ users}}" +
      "</ul>").in
    ).render(
        ["users":[
            ["email":"alice@example.org"
              ,"login":"alice"]
            ,["email":"bob@example.org"
              ,"login":"bob"]
        ]]
    )
    
    verifyEq(result, "<ul><li><img src=\"https://secure.gravatar.com/avatar/fbf7c6aec1d4280b7c2704c1c0478bd6?s=30\">alice</li><li><img src=\"https://secure.gravatar.com/avatar/10ac39056a4b6f1f6804d724518ff2dc?s=30\">bob</li></ul>")
  }

  Void testChildrenHelper()
  {
    userList := Mustache(
        ("<ul>" +
          "{{# users}}" +
            "<li><img src=\"{{ gravatar }}\">{{ login }}</li>" +
          "{{/ users}}" +
        "</ul>").in
      )

    page := Mustache("<html><body>{{>userList}}</body></html>".in)
    root := GravatarMustache(true, "{{>content}}".in)

    result := root.render(
        ["users":[
            ["email":"alice@example.org"
              ,"login":"alice"]
            ,["email":"bob@example.org"
              ,"login":"bob"]
        ]]
        ,["content": page, "userList":userList]
    )

    verifyEq(result,"""<html><body><ul><li><img src="https://secure.gravatar.com/avatar/fbf7c6aec1d4280b7c2704c1c0478bd6?s=30">alice</li><li><img src="https://secure.gravatar.com/avatar/10ac39056a4b6f1f6804d724518ff2dc?s=30">bob</li></ul></body></html>""")

    }


}

