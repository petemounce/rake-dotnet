# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake_dotnet'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'Demo'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'DemoCompany'
RDNVERSION = Versioner.new.get

assembly_info_cs = File.join(SRC_DIR,'AssemblyInfo.cs')
Rake::AssemblyInfoTask.new(assembly_info_cs) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT_NAME
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
	ai.version = RDNVERSION
end

bin_out = File.join(OUT_DIR, 'bin')
Rake::MsBuildTask.new({:verbosity=>MSBUILD_VERBOSITY, :deps=>[bin_out, :assembly_info]})

Rake::HarvestOutputTask.new({:deps => [:compile]})

Rake::XUnitTask.new({:options=>{:html=>true,:xml=>true}, :deps=>[:compile, :harvest_output]})
Rake::FxCopTask.new({:deps=>[:compile, :harvest_output]})
Rake::NCoverTask.new({:deps=>[:compile, :harvest_output], :ncover_options=>{:arch=>'amd64'}, :ncover_reporting_options=>{:arch=>'amd64'}})

demo_site = File.join(OUT_DIR, 'Demo.Site')
Rake::HarvestWebApplicationTask.new({:deps=>[:compile]})

Rake::RDNPackageTask.new(name='bin', version=RDNVERSION, {:deps=>[:harvest_output, :xunit]}) do |p|
	p.targets.include("#{bin_out}/*")
end
Rake::RDNPackageTask.new(name='Demo.Site', version=RDNVERSION, {:deps=>[:harvest_webapps, :xunit]}) do |p|
	p.targets.include("#{demo_site}/*")
end

task :default => [:compile, :harvest_output, :xunit, :package]
