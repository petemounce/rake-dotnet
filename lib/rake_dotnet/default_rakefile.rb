require 'rake'
require '../rake_dotnet'

AssemblyInfoTask.new

MsBuildTask.new({:deps=>[Bin_out, :assembly_info]})

HarvestOutputTask.new({:deps => [:compile]})

HarvestWebApplicationTask.new({:deps=>[:compile]})

RDNPackageTask.new(name='bin', {:deps=>[:compile, :harvest_output, :xunit]}) do |p|
	p.targets.include("#{Bin_out}")
end

task :default => [:compile, :harvest_output, :xunit, :package]
