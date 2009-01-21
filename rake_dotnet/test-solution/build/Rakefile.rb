# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake/clean'

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
require '../../rake_dotnet'
require '../../assemblyinfo'
require '../../file'
require '../../harvester'
require '../../msbuild'
require '../../package'
require '../../svn'
require '../../version'
require '../../xunit'

# allows you to do things like 'rake compile CONFIGURATION=Release' to specify these options
# By default, we assume that this Rakefile lives in {root}/build
PRODUCT = ENV['PRODUCT'] ? ENV['PRODUCT'] : 'Yoti'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'YotiCo'
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'
XUNIT_OPTS = {:html=>true}
ROOT = ENV['ROOT'] ? ENV['ROOT'] : '..'
OUT_DIR = ENV['OUT_DIR'] ? ENV['OUT_DIR'] : 'out'
TOOLS_DIR = ENV['TOOLS_DIR'] ? ENV['TOOLS_DIR'] : File.join(ROOT, 'lib')

# Source files
src_dir = File.join(ROOT, 'src')

# Generated files
version_txt = File.join(OUT_DIR, 'version.txt')
assembly_info_cs = File.join(src_dir,'AssemblyInfo.cs')
bin_out = File.join(OUT_DIR, 'bin', CONFIGURATION)
reports_out = File.join(OUT_DIR, 'reports')
demo_site = File.join(OUT_DIR, 'Demo.Site')

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include("#{src_dir}/**/obj")
CLEAN.include("#{src_dir}/**/bin")
CLEAN.include("#{src_dir}/**/AssemblyInfo.cs")
CLEAN.include(version_txt)
CLOBBER.include(OUT_DIR)


Rake::VersionTask.new(version_txt, {:tools_dir=>TOOLS_DIR})

Rake::AssemblyInfoTask.new(assembly_info_cs, version_txt) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
end

Rake::MsBuildTask.new(name=:compile, {:src_dir=>src_dir, :out_dir=>bin_out, :verbosity=>MSBUILD_VERBOSITY, :deps=>[bin_out, :version, :assembly_info]})

Rake::XUnitTask.new(name=:test, {:suites_dir=>bin_out, :reports_dir=>reports_out, :options=>XUNIT_OPTS, :deps=>[:compile]})

Rake::RDNPackageTask.new(name='bin', {:in_dir=>bin_out, :out_dir=>OUT_DIR, :path_to_snip=>OUT_DIR, :deps=>[:compile]})

Rake::HarvestWebApplicationTask.new({:src_path=>src_dir, :target_path=>OUT_DIR, :deps=>[:compile], :tools_dir => TOOLS_DIR})

Rake::RDNPackageTask.new(name=demo_site, {:in_dir=>demo_site, :out_dir=>OUT_DIR, :path_to_snip=>OUT_DIR, :deps=>[:harvest_webapps]})

desc "Compile all the projects in #{PRODUCT}.sln"
task :compile_sln => [:version, :assembly_info] do |t|
	mb = MsBuild.new("#{PRODUCT}.sln", {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
	mb.run
end

task :default => [:package]