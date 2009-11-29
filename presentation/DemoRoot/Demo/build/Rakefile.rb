# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require '../../../../lib/rake_dotnet.rb'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'Demo'
COMPANY_NAME = ENV['COMPANY_NAME'] ? ENV['COMPANY_NAME'] : 'DemoCompany'

demo_site = File.join(RakeDotNet::OUT_DIR, "Demo.Site")

RakeDotNet::AssemblyInfoTask.new

RakeDotNet::MsBuildTask.new({:deps=>[:assembly_info]})

RakeDotNet::HarvestOutputTask.new({:deps => [:compile]})

RakeDotNet::HarvestWebApplicationTask.new({:deps=>[:compile]})

RakeDotNet::RDNPackageTask.new(name='bin', {:deps=>[:compile, :harvest_output, :xunit]}) do |p|
	p.targets.include("#{RakeDotNet::Bin_out}")
end

RakeDotNet::XUnitTask.new({:options=>{:html=>true}})
RakeDotNet::RDNPackageTask.new(name='Demo.Site', {:deps=>[:compile, :harvest_webapps, :xunit]}) do |p|
	p.targets.include("#{demo_site}")
	p.targets.exclude("#{demo_site}**/obj")
end

RakeDotNet::FxCopTask.new do |fxc|
	fxc.dll_list.exclude("#{fxc.suites_dir}/**/*Tests*.dll")
end
RakeDotNet::NCoverTask.new


task :default => [:compile, :harvest_output, :xunit, :package]
task :first_checkout => [:clobber, :assembly_info]

