# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake/clean'

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
require '../rake_dotnet'
require '../assemblyinfo'
require '../file'
require '../harvester'
require '../msbuild'
require '../package'
require '../svn'
require '../version'
require '../xunit'

# allows you to do things like 'rake compile CONFIGURATION=Release' to specify these options
PRODUCT = ENV['PRODUCT'] ? ENV['PRODUCT'] : 'Yoti'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'YotiCo'
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'
XUNIT_OPTS = {:html=>true}

# Source files
srcDir = 'src'

# Generated files
buildDir = 'build'
binDir = File.join(buildDir, 'bin', CONFIGURATION)
reportsDir = File.join(buildDir, 'reports')
versionTxt = File.join(buildDir,'version.txt')
asmInfoCs = File.join(srcDir,'AssemblyInfo.cs')

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include('src/**/obj')
CLEAN.include('src/**/bin')
CLEAN.include('src/**/AssemblyInfo.cs')
CLOBBER.include(buildDir)


Rake::VersionTask.new(versionTxt)
Rake::AssemblyInfoTask.new(asmInfoCs, versionTxt) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
end
Rake::MsBuildTask.new(name=:compile, {:src_dir=>srcDir, :out_dir=>binDir, :verbosity=>MSBUILD_VERBOSITY, :deps=>[binDir, :version, :assembly_info]})
Rake::XUnitTask.new(name=:test, {:suites_dir=>binDir, :reports_dir=>reportsDir, :opts=>XUNIT_OPTS, :deps=>[:compile]})
Rake::RDNPackageTask.new(name=:bin, {:in_dir=>binDir, :out_dir=>buildDir, :path_to_snip=>buildDir, :deps=>[:compile]})

desc "Compile all the projects in #{PRODUCT}.sln"
task :compile_sln => [:version, :assembly_info] do |t|
	mb = MsBuild.new("#{PRODUCT}.sln", {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
	mb.run
end
