# Documentation: http://rake.rubyforge.org/ -> Files/doc/rakefile.rdoc
require 'rake'
require 'rake/tasklib'
require 'rake/clean'

# Documentation: http://rake_dotnet.rubyforge.org/ -> Files/doc/rake_dotnet.rdoc
require '../rake_dotnet'
require '../assemblyinfo'
require '../file'
require '../harvester'
require '../msbuild'
require '../svn'
require '../version'

PRODUCT = ENV['PRODUCT'] ? ENV['PRODUCT'] : 'Yoti'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'YotiCo'
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'

# Source files
srcDir = 'src'

# Generated files
buildDir = 'build'
versionTxt = File.join(buildDir,'version.txt')
asmInfoCs = File.join(srcDir,'AssemblyInfo.cs')
projects = 'solution_projects.txt'

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include('src/**/obj')
CLEAN.include('src/**/bin')
CLEAN.include('src/**/AssemblyInfo.cs')
CLEAN.include('solution_projects.txt')
CLOBBER.include(buildDir)

project_list = FileList.new('src/**/*.*proj')

directory buildDir

Rake::VersionTask.new(versionTxt)
Rake::AssemblyInfoTask.new(asmInfoCs, versionTxt) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
end

task :compile_sln => [:version, :assembly_info] do |t|
	mb = MsBuild.new("#{PRODUCT}.sln", {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
	mb.run
end

task :compile,[:projects] => [binDir, :version, :assembly_info] do |t, args|
	args.with_defaults(:projects => project_list)
	h = Harvester.new(binDir)
	args.projects.each do |p|
		mb = MsBuild.new(p, {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
		mb.run
		isWeb = p.match(/Web\./)
		if (isWeb)
			h.add(p.pathmap("%d/bin/**/*"))
		else
			h.add(p.pathmap("%d/bin/#{CONFIGURATION}/**/*"))
		end
	end
	h.harvest
end
