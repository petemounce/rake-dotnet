# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'Pathname'
require 'rake/clean'

Hoe.spec 'rake-dotnet' do |p|
	p.version = '0.1.20'
	p.author = 'Peter Mounce'
	p.description = 'Making a .NET build-automation dev\'s life easier, one angle-bracket at a time'
	p.email = 'public@neverrunwithscissors.com'
	p.summary = 'Build automation for .NET builds'
	p.rubyforge_name = 'rake-dotnet' # if different than lowercase project name
	p.developer('Peter Mounce', 'public@neverrunwithscissors.com')
	p.remote_rdoc_dir = ''
	p.extra_deps << ['rake', '>= 0.8.3']
	p.url = 'http://blog.neverrunwithscissors.com/tag/rake-dotnet'
end

generated_library = File.join('lib', 'rake_dotnet.rb')
CLOBBER.include generated_library
file generated_library do |f|
	text = ''
	files = ['header.rb', 'defaults.rb', 'cli.rb', 'bcpcmd.rb', 'sqlcmd.rb', 'assemblyinfo.rb', 'fxcop.rb', 'harvester.rb', 'msbuild.rb', 'ncover.rb', 'package.rb', 'sevenzip.rb', 'svn.rb', 'version.rb', 'xunit.rb', 'footer.rb']
	gl = File.open(generated_library, 'a')
	files.each do |file|
		text = File.read(File.join('lib', file))
		gl.puts text
		gl.puts ''
		gl.puts ''
	end
	gl.close unless gl.closed?
end

desc 'Generate the concatenated library'
task :generate_lib => generated_library

task :check_manifest => generated_library

task :test => generated_library

task :uninstall_gem do
	sh "gem uninstall rake-dotnet"
end

require 'spec/rake/spectask'

desc 'Run all examples and report'
Spec::Rake::SpecTask.new('examples_with_report') do |t|
	t.spec_files = FileList['spec/**/*.rb']
	t.spec_opts = ["--format", "html:doc/examples.html", "--diff"]
	t.fail_on_error = false
end

desc "Run all specs with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
	t.spec_files = FileList['spec/**/*.rb']
	t.rcov = true
	t.rcov_opts = ['--exclude', 'spec']
end
# vim: syntax=Ruby

task :spec => generated_library
file 'coverage/index.html'  => [:examples_with_rcov]
file 'doc/examples.html'  => [:examples_with_report]

task :package => [:spec, :examples_with_rcov, :examples_with_report]
task :release => [:examples_with_rcov, :examples_with_report]
