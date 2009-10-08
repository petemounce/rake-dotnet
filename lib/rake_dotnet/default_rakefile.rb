require 'rake'
require 'rake_dotnet'

RakeDotNet::AssemblyInfoTask.new

RakeDotNet::MsBuildTask.new({:deps=>[RakeDotNet::Bin_out, :assembly_info]})

RakeDotNet::HarvestOutputTask.new({:deps => [:compile]})

RakeDotNet::HarvestWebApplicationTask.new({:deps=>[:compile]})

RakeDotNet::RDNPackageTask.new(name='bin', {:deps=>[:compile, :harvest_output, :xunit]}) do |p|
	p.targets.include("#{RakeDotNet::Bin_out}")
end

task :default => [:compile, :harvest_output, :xunit, :package]
