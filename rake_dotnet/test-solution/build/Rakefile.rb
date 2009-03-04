# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
require '../../rake_dotnet'

assembly_info_cs = File.join(SRC_DIR,'AssemblyInfo.cs')
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
Rake::XUnitTask.new({:suites_dir=>bin_out, :reports_dir=>reports_out, :options=>XUNIT_OPTS, :deps=>[:compile, :harvest_output]})

demo_site = File.join(OUT_DIR, 'Demo.Site')
Rake::HarvestWebApplicationTask.new({:deps=>[:compile]})

Rake::RDNPackageTask.new(name='bin', version=RDNVERSION, {:in_dir=>bin_out, :deps=>[:harvest_output, :xunit]})
Rake::RDNPackageTask.new(name='Demo.Site', version=RDNVERSION, {:in_dir=>demo_site, :deps=>[:harvest_webapps, :xunit]})

task :default => [:compile, :harvest_output, :xunit, :package]