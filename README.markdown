# rake-dotnet

[Rake on my blog](http://blog.neverrunwithscissors.com/tag/rake), [Rake-dotnet on my blog](http://blog.neverrunwithscissors.com/tag/rake-dotnet)

## DESCRIPTION:

rake-dotnet is a library of custom tasks designed to (try to!) make your life as a build-automation author easier.

When have you ever heard of a build-script called anything other than a script?  msbuild and nant both try to get you to call them projects.  I'll say it up front - the idea of using XML to declaratively define the sequence of hoops one gets the computer to jump through to turn source into packaged software never sat right with me.  I looked for something better one day, and found rake.  I haven't touched msbuild or nant since, and I've been happier ;-)

Rake-dotnet is a bunch of things that aim at doing the work of creating a featureful build-script, so you don't have to.  RDN likes convention-over-configuration.  RDN tries to keep the Rakefile (the part YOU have to get involved with) short, because that means you can get on with the business of making software that YOU care about.  RDN is designed to try to waste as little of your time as possible (and I'd like to know whether I succeeded, or failed, please ;-) ).

## Features

*	Generate AssemblyInfo.cs file(s) for watermarking assemblies with:
	*	major.minor.build.svn-revision version number (git is handled differently) (build number is 0 when built outside of CI)
	*	product-name
	*	company-name
	*	build configuration (Release/Debug etc)
	*	build-date
*	Build the project files to produce said DLLs (call msbuild against the project file(s))
*	Run NUnit tests against said DLLs, and output an XML report (wrap nunit.console.exe)
*	Run XUnit.NET tests against said DLLs, and output reports (wrap xunit.console.exe)
*	Run FxCop against said DLLs, and output reports (wrap fxcopcmd.exe)
*	Run NCover against build output to generate coverage metrics
*	Run NCover against coverage to generate coverage reports
*	Run NDepend against build output to generate reports (based on an ndepend project file)
*	Harvest build output to a single directory tree for ease of working with it
*	Package build output as a zip file, naming it like {product-name}-{configuration}-v{version}.zip
*	Integrates well with TeamCity continuous integration

## Problems:

*	Relies on a whole bunch of third-party tools and libraries which are too big to distribute within the gem or host myself.  So users need to fetch these before they can get up and running.  So think of a way to make this more frictionless...
	*	InstallPad?
	*	Currently, the directories for each tool are created within [{github}/presentation/DemoRoot/3rdparty](http://github.com/petemounce/rake-dotnet/tree/master) and there is a readme.txt next-door with URLs to fetch from.

## Conventions:

The tasks rely on you following some conventions.  These are configurable to some extent, by calling rake to pass in values for the constants.

*	`PRODUCT_ROOT` defaults to `..` - rake's working directory is `build/`, where Rakefile.rb is used.  All paths are relative to the rake working directory.
*	`OUT_DIR` defaults to `out`, hence equivalent to `#{PRODUCT_ROOT}/build/out` - build-output gets squirted here.
*	`SRC_DIR` defaults to `#{PRODUCT_ROOT}/src` -  buildable projects should live here (this includes test projects).  One directory per project, directory-name matches project-filename matches generated assembly-name. 
*	`TOOLS_DIR` defaults to `#{PRODUCT_ROOT}/../3rdparty` - intentionally, tools are kept outside of the source tree.  This allows for efficient xcopy deployment, or a source-control symbolic link arrangement (svn:externals works well).
*	test projects should have `Tests` somewhere in their project-name.
*	web-application projects should have `Site` somewhere in their project-name.
*	msbuild is assumed to follow its defaults and output into `#{SRC_DIR}/{project-being-built}/bin/{configuration}` for class libraries and so forth.

So our source structure looks like:
	
	/
		/3rdparty - contains tools, one directory per tool
		/Foo
			/build
				/Rakefile.rb
			/src
				/Foo.Bar
					/Foo.Bar.csproj
					{files}
			/Foo.sln
		/OtherProduct
			/build
				/Rakefile.rb
			/src
				/OtherProduct.Core
					/OtherProduct.Core.csproj
					{files}
			/OtherProduct.sln

Example: [{github}/presentation/DemoRoot](http://github.com/petemounce/rake-dotnet/tree/master)

## Roadmap:

(In no particular order)

*	rdoc documentation to supplement blog'd about
*	Support other test-runners - nunit, mbunit, gallio
*	Support other source-controls to get build version number - mercurial, cvs(?), TFS.  Or just read it from an environment variable that assumes we're within a CI build.
*	Support changing the conventions to allow users to specify their own source structure
*	Provide an InstallPad for the 3rdparty bits

## Requirements:

*	ruby 1.8.6+ [ruby one-click installer](http://rubyinstaller.org)
*	rake 0.8.3+ (but this will be installed when you do `gem install rake-dotnet`)

## Install:

1. Install Ruby 1.8.6 using the [ruby one-click installer](http://rubyinstaller.org) to (eg) `c:\ruby`
2. `gem install rake-dotnet` (prepend `sudo` if you're not on Windows - which doesn't seem likely considering the audience ;-) )
3. Create a directory to hold 3rdparty dependencies
	* if you follow the instructions in  [{github}/presentation/DemoRoot/3rdparty/readme.txt](http://github.com/petemounce/rake-dotnet/tree/master/) you'll get default paths that rake-dotnet expects
	* if you mirror the structure as above, you won't need to pass in a value for TOOLS_DIR when calling rake
4. Fetch the 3rdparty dependencies listed in [{github}/presentation/DemoRoot/3rdparty/readme.txt](http://github.com/petemounce/rake-dotnet/tree/master/)
	* rake-dotnet uses tools within the paths taken from the default unzip'd location.  For example, svn.exe is expected to live within #{TOOLS_DIR}/svn/bin because that's how svn zip files unzip

## Build from source:
1. On Windows, you need the [ruby-installer development kit](http://wiki.github.com/oneclick/rubyinstaller/development-kit) (the `rcov` gem needs to build its native extension)
2. `gem install rcov syntax hoe rspec diff-lcs --include-dependencies` (again, prepend `sudo` if you're not on Windows)
3. Edit `c:\Ruby\lib\ruby\gems\1.9.1\gems\hoe-2.4.0\lib\hoe.rb` [per here](http://blog.emson.co.uk/2008/06/an-almost-fix-for-creating-rubygems-on-windows/)
4. `rake clobber examples_with_report` and/or `rake clobber examples_with_rcov` to run specifications and coverage respectively; library itself will be generated to `lib/rake_dotnet.rb` by cat'ing files together.

## License:

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
