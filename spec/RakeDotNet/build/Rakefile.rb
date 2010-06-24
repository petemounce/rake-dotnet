# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake_dotnet_for_spec.rb'
require 'erb'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'RakeDotNet'
COMPANY_NAME = ENV['COMPANY_NAME'] ? ENV['COMPANY_NAME'] : 'neverrunwithscissors.com'

AssemblyInfoTask.new

MsBuildTask.new({:dependencies=>[:assembly_info]})

HarvestOutputTask.new({:dependencies => [:compile]})

RDNPackageTask.new(:name=>'bin', :dependencies=>[:compile, :harvest, :tests]) do |p|
	p.items << {:from=>Bin_out}
end
RDNPackageTask.new(:name=>'RakeDotNet.WdpSite', :dependencies=>[:compile, :harvest, :tests]) do |p|
	p.items << {:from => File.join(SRC_DIR, 'RakeDotNet.WdpSite', CONFIGURATION),
	            :named=>'RakeDotNet.WdpSite'}
end
RDNPackageTask.new(:name => 'RakeDotNet.WebApp.Site', :dependencies=>[:compile, :harvest, :tests]) do |p|
	p.items << {:from => File.join(SRC_DIR, 'RakeDotNet.WebApp.Site'),
	            :exclude=>['**/*.cs', '**/*.csproj', '**/Properties']}
end
RDNPackageTask.new(:name=>'RakeDotNet', :dependencies=>[:compile, :harvest, :tests, :ndepend, :coverage, :fxcop]) do |p|
	p.items << {:from => File.join(SRC_DIR, 'RakeDotNet.WdpSite', CONFIGURATION),
	            :named=>'RakeDotNet.WdpSite'}
	p.items << {:from => File.join(SRC_DIR, 'RakeDotNet.WebApp.Site'),
	            :exclude=>['**/*.cs', '**/*.csproj', '**/Properties']}
	p.items << {:from => File.join(OUT_DIR, 'reports')}
end

XUnitTask.new

FxCopTask.new

NCoverTask.new do |nc|
	nc.profile_options[:test_framework] = :xunit
	nc.reporting_options[:reports] =
			['Summary', 'UncoveredCodeSections', 'FullCoverageReport', 'SymbolModule',
			 'SymbolModuleNamespace', 'SymbolModuleNamespaceClass', 'SymbolCCModuleClassFailedCoverageTop',
			 'MethodModule', 'MethodModuleNamespaceClass', 'MethodCCModuleClassFailedCoverageTop']
	nc.should_publish = true
end

NDependTask.new

task :default => [:templates, :compile, :harvest, :tests, :coverage, :fxcop, :ndepend, :package]
task :first_checkout => [:clobber, :templates]
