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

# Setting constants like this allows you to do things like 'rake compile CONFIGURATION=Release' to specify their values
# By default, we assume that this Rakefile lives in {PRODUCT_ROOT}/build, and that this is the working directory
PRODUCT_ROOT = ENV['PRODUCT_ROOT'] ? ENV['PRODUCT_ROOT'] : '..'
TOOLS_DIR = ENV['TOOLS_DIR'] ? ENV['TOOLS_DIR'] : File.join(PRODUCT_ROOT, '..', '3rdparty')
PRODUCT = ENV['PRODUCT'] ? ENV['PRODUCT'] : 'Yoti'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'YotiCo'
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'
OUT_DIR = ENV['OUT_DIR'] ? ENV['OUT_DIR'] : 'out'
XUNIT_OPTS = {:html=>true}
# Versioner depends on SvnInfo which depends on TOOLS_DIR being set
RDNVERSION = Versioner.new.get

src_dir = File.join(PRODUCT_ROOT, 'src')

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include("#{src_dir}/**/obj")
CLEAN.include("#{src_dir}/**/bin")
CLEAN.include("#{src_dir}/**/AssemblyInfo.cs")
CLOBBER.include(OUT_DIR)


assembly_info_cs = File.join(src_dir,'AssemblyInfo.cs')
Rake::AssemblyInfoTask.new(assembly_info_cs) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
	ai.version = RDNVERSION
end

bin_out = File.join(OUT_DIR, 'bin')
Rake::MsBuildTask.new({:out_dir=>bin_out, :verbosity=>MSBUILD_VERBOSITY, :configuration=>CONFIGURATION, :deps=>[bin_out, :assembly_info]})

Rake::HarvestOutputTask.new({:deps => [:compile]})

reports_out = File.join(OUT_DIR, 'reports')
Rake::XUnitTask.new({:suites_dir=>bin_out, :reports_dir=>reports_out, :options=>XUNIT_OPTS, :deps=>[:compile]})
task :xunit => :harvest_output

demo_site = File.join(OUT_DIR, 'Demo.Site')
Rake::HarvestWebApplicationTask.new({:deps=>[:compile]})

Rake::RDNPackageTask.new(name='bin', version=RDNVERSION, {:in_dir=>bin_out, :deps=>[:harvest_output, :xunit]})
Rake::RDNPackageTask.new(name='Demo.Site', version=RDNVERSION, {:in_dir=>demo_site, :deps=>[:harvest_webapps, :xunit]})

task :default => [:compile, :harvest_output, :xunit, :package]