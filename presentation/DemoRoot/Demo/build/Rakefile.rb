# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake_dotnet'

PRODUCT_NAME = ENV['PRODUCT_NAME'] ? ENV['PRODUCT_NAME'] : 'Demo'
COMPANY_NAME = ENV['COMPANY_NAME'] ? ENV['COMPANY_NAME'] : 'DemoCompany'

bin_out = File.join(OUT_DIR, "bin-#{CONFIGURATION}-v#{RDNVERSION}")
demo_site = File.join(OUT_DIR, "Demo.Site-#{CONFIGURATION}-v#{RDNVERSION}")

Rake::AssemblyInfoTask.new
Rake::MsBuildTask.new({:verbosity=>MSBUILD_VERBOSITY, :deps=>[bin_out, :assembly_info]})
Rake::XUnitTask.new({:options=>{:html=>true}})
Rake::HarvestOutputTask.new({:deps => [:compile]})
Rake::HarvestWebApplicationTask.new({:deps=>[:compile]})
Rake::RDNPackageTask.new(name='bin', version=RDNVERSION, {:deps=>[:compile, :harvest_output, :xunit]}) do |p|
	p.targets.include("#{bin_out}")
end
Rake::RDNPackageTask.new(name='Demo.Site', version=RDNVERSION, {:deps=>[:compile, :harvest_webapps, :xunit]}) do |p|
	p.targets.include("#{demo_site}")
	p.targets.exclude("#{demo_site}**/obj")
end

Rake::FxCopTask.new do |fxc|
	fxc.dll_list.exclude("#{fxc.suites_dir}/**/*Tests*.dll")
end
Rake::NCoverTask.new


task :default => [:compile, :harvest_output, :xunit, :package]


# below here is stuff that will be refactored into rake-dotnet, but isn't yet...
desc "Our script uploads artifacts that have a version/configuration in their name; sort it out for the runners after the initial build"
task :ci_kludge do
	# yes, I know this is a disgustingly brittle way to do it.
	fl = FileList.new('out/bin*')
	fl.each do |f|
		pn = Pathname.new(f)
		pn.rename 'out/bin'
	end
end

task :first_checkout => [:clobber, :assembly_info]