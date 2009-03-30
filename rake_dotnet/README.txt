= rakedotnet

* http://blog.neverrunwithscissors.com/tag/rake

== DESCRIPTION:

Rake dotnet is a library of custom tasks designed to (try to!) make your life as a build-automation author easier.

When have you ever heard of a build-script called anything other than a script?  msbuild and nant both try to get you to call them projects.  I'll say it up front - the idea of using XML to declaratively define the sequence of hoops one gets the computer to jump through to turn source into packaged software never sat right with me.  I looked for something better one day, and found rake.  I haven't touched msbuild or nant since, and I've been happier ;-)

Rake dotnet is a bunch of things that aim at doing the work of creating a featureful build-script, so you don't have to.  RDN likes convention-over-configuration.  RDN tries to keep the Rakefile (the part YOU have to get involved with) short, because that means you can get on with the business of making software that YOU care about.  RDN is designed to try to waste as little of your time as possible (and I'd like to know whether I succeeded, or failed, please ;-) ).

== FEATURES/PROBLEMS:

* Generate AssemblyInfo.cs file(s) for watermarking assemblies with:
	* major.minor.build.svn-revision version number
	* product-name
	* company-name
	* build configuration
* Build the project files to produce said DLLs (call msbuild against the project file(s))
* Run XUnit.NET unit tests against said DLLs, and output reports (wrap xunit.console.exe)
* Run FxCop against said DLLs, and output reports (wrap fxcopcmd.exe)
* Run NCover against build output to generate coverage metrics
* Run NCover against coverage to generate coverage reports
* Harvest build output
* Package build output as a zip file, naming it like {product-name}-{configuration}-v{version}.zip

== ROADMAP:

(In no particular order)
* rdoc documentation to supplement blog'd about
* unit-tests
* Support other test-runners - nunit, mbunit, gallio
* unit-tests!
* Support code-coverage runner(s) - ncover 1.68, ncover 3, partcover
* unit-tests!!
* Support clone-detective...?
* unit-tests!!!
* Support other source-controls to get build version number - git, mercurial, cvs(?), TFS
* unit-tests!!!!
* Support changing the conventions to allow users to specify their own source structure
* unit-tests
* Provide an InstallPad for the 3rdparty bits

== REQUIREMENTS:

* ruby 1.8.6+
* rake 0.8.3+

== INSTALL:

* sudo gem install rake-dotnet

== LICENSE:

(The MIT License)

Copyright (c) 2009 Peter Mounce

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
