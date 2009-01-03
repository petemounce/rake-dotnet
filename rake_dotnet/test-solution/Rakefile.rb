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
require '../xunit'

# allows you to do things like 'rake compile CONFIGURATION=Release' to specify these options
PRODUCT = ENV['PRODUCT'] ? ENV['PRODUCT'] : 'Yoti'
COMPANY = ENV['COMPANY'] ? ENV['COMPANY'] : 'YotiCo'
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'
XUNIT_OPTS = {:html=>true}

# Source files
srcDir = 'src'

# Generated files
buildDir = 'build'
binDir = File.join(buildDir, 'bin', CONFIGURATION)
reportsDir = File.join(buildDir, 'reports')
versionTxt = File.join(buildDir,'version.txt')
asmInfoCs = File.join(srcDir,'AssemblyInfo.cs')

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include('src/**/obj')
CLEAN.include('src/**/bin')
CLEAN.include('src/**/AssemblyInfo.cs')
CLOBBER.include(buildDir)

project_list = FileList.new('src/**/*.*proj')

directory buildDir
directory binDir
directory reportsDir

Rake::VersionTask.new(versionTxt)
Rake::AssemblyInfoTask.new(asmInfoCs, versionTxt) do |ai|
	# TODO: Read {configuration, product, company} from Rakefile.yaml config file ?
	ai.product_name = PRODUCT
	ai.company_name = COMPANY
	ai.configuration = CONFIGURATION
end
Rake::XUnitTask.new(name=:test, suites_dir=binDir, reports_dir=reportsDir, opts=XUNIT_OPTS)

rule(/build\/bin\/#{CONFIGURATION}\/[\w\.]+\.dll/) do |r|
	pn = Pathname.new(r.name)
	name = pn.basename.to_s.sub('.dll', '')
	project = File.join(srcDir, name, name + '.csproj')
	mb = MsBuild.new(project, {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
	mb.run
	h = Harvester.new(binDir)
	isWeb = project.match(/src\/Web\..*\//)
	if (isWeb)
		h.add(project.pathmap("%d/bin/**/*"))
	else
		h.add(project.pathmap("%d/bin/#{CONFIGURATION}/**/*"))
	end
	h.harvest
end


desc "Compile all the projects in #{PRODUCT}.sln"
task :compile_sln => [:version, :assembly_info] do |t|
	mb = MsBuild.new("#{PRODUCT}.sln", {:Configuration => CONFIGURATION}, ['Build'], MSBUILD_VERBOSITY)
	mb.run
end

desc "Compile the specified projects (give relative paths) (otherwise, all matching src/**/*.*proj) and harvest output to #{binDir}"
task :compile,[:projects] => [binDir, :version, :assembly_info] do |t, args|
	args.with_defaults(:projects => project_list)
	args.projects.each do |p|
		pn = Pathname.new(p)
		dll = File.join(binDir, pn.basename.sub(pn.extname, '.dll'))
		Rake::FileTask[dll].invoke
	end
end

task :test => [:compile]