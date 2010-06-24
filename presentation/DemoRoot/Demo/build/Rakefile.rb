# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require '../../../../lib/rake_dotnet.rb'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'Demo'
COMPANY_NAME = ENV['COMPANY_NAME'] ? ENV['COMPANY_NAME'] : 'DemoCompany'

AssemblyInfoTask.new

MsBuildTask.new({:dependencies=>[:assembly_info]})

HarvestOutputTask.new({:dependencies => [:compile]})

XUnitTask.new({:options=>{:html=>true}})

FxCopTask.new do |fxc|
  fxc.dll_list.exclude("#{fxc.suites_dir}/**/*Tests*.dll")
end

NCoverTask.new

RDNPackageTask.new(:name=>'bin', :dependencies=>[:compile, :harvest_output, :xunit]) do |p|
  p.items << {:from=>Bin_out}
end

RDNPackageTask.new(:name=>'Demo.Site', :dependencies=>[:compile, :harvest_webapps, :xunit]) do |p|
  p.items << {:from => File.join(SRC_DIR, "Demo.Site"),
              :exclude => ['**/obj']}
end

task :default => [:compile, :harvest_output, :xunit, :package]
task :first_checkout => [:clobber, :assembly_info]

