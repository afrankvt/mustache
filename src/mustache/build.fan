#! /usr/bin/env fan

using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "mustache"
    summary = "Logic-less templates"
    version = Version("1.0")
    meta = [
      "org.name":     "Xored",
      "org.uri":      "http://www.xored.com",
      "proj.name":    "Mustache",
      "proj.uri":     "http://mustache.github.io",
      "license.name": "MIT",
      "vcs.name":     "Git",
      "vcs.uri":      "https://github.com/afrankvt/mustache",
      "repo.public":  "true",
      "repo.tags":    "web"
    ]
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
    resDirs = [`doc/`]
  }
}
