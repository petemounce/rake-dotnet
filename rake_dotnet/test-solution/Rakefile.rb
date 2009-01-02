# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake/clean'

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include('src/**/obj')
CLEAN.include('src/**/bin')
CLEAN.include('src/**/AssemblyInfo.cs')
CLOBBER.include('build')

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
require '../rake_dotnet'
require '../assemblyinfo'
require '../svn'
require '../version'

buildDir = 'build'
directory buildDir
versionTxt = File.join('build','version.txt')

Rake::VersionFileTask.new(versionTxt)

