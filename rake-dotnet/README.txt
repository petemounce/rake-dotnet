= rake-dotnet

* http://neverrunwithscissors.com/projects/rake-dotnet

== DESCRIPTION:

A number of custom rake tasks that wrap some .NET development tools like XUnit.NET, NCover, etc to enable them to be used with less work in build automation; I learned this stuff to be able to get rid of msbuild and nant which were tools that caused friction for me.

== FEATURES/PROBLEMS:

+ By-convention, rules-based building.  Minimal Rakefile required; the goal is to keep this as slim as possible for ease of getting up and running (obviously, the audience of .NET developers is unlikely to know Ruby; I certainly didn't when I started using rake)
+ Wrap useful tools:
++ version.rb: Figure out the svn revision of the working copy being built from; store this in a text file for later tasks
++ assemblyinfo.rb: Find and replace tokens in a template file to generate an AssemblyInfo.cs file
+++ built-on
+++ company-name
+++ product-name
+++ version
++ msbuild.rb: Look for project files and build them.  Harvest their output to a central location for later tasks
++ harvester.rb: Harvest a web application for deployment
++ xunit.rb: Look for test DLLs and use the console runner to run them, optionally generating reports
++ package.rb: Zip up (requires cygwin zip in the path) directories for packaging


== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* rake
* the underlying tools that these tasks wrap

== INSTALL:

* sudo gem install rake-dotnet

== LICENSE:

(The MIT License)

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
