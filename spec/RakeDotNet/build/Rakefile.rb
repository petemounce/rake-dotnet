# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake_dotnet_for_spec.rb'
require 'erb'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'RakeDotNet'
COMPANY_NAME = ENV['COMPANY_NAME'] ? ENV['COMPANY_NAME'] : 'neverrunwithscissors.com'

AssemblyInfoTask.new

MsBuildTask.new({:deps=>[:assembly_info]})

HarvestOutputTask.new({:deps => [:compile]})

HarvestWebApplicationTask.new({:deps=>[:compile]})
HarvestWebDeploymentTask.new(:dependencies=>[:compile])

RDNPackageTask.new(name='bin', {:deps=>[:compile, :harvest, :xunit]}) do |p|
	p.targets.include("#{Bin_out}")
end

XUnitTask.new

FxCopTask.new do |fxc|
	fxc.dll_list.exclude("#{fxc.suites_dir}/**/*Tests.dll")
end

NCoverTask.new do |nc|
	nc.profile_options[:test_framework] = :xunit
	nc.reporting_options[:reports] = 
		['Summary', 'UncoveredCodeSections', 'FullCoverageReport', 'SymbolModule',
		'SymbolModuleNamespace', 'SymbolModuleNamespaceClass', 'SymbolCCModuleClassFailedCoverageTop', 
		'MethodModule', 'MethodModuleNamespaceClass', 'MethodCCModuleClassFailedCoverageTop']
end

NDependTask.new

task :default => [:compile, :harvest, :xunit, :package]
task :first_checkout => [:clobber, :assembly_info]
