# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'Pathname'
require 'rake'
require 'rake/clean'

VERSION = ENV['VERSION']

Hoe.spec 'rake-dotnet' do
  developer('Peter Mounce', 'public@neverrunwithscissors.com')
  self.summary = 'A collection of custom-tasks to make a .NET project easily buildable via command-line automation'
  self.description = 'Removing angle brackets from a .NET build-guy\'s life one at a time...'
  #self.homepage = 'http://github.com/petemounce/rake-dotnet'
  self.version = VERSION
  self.extra_deps << ['rake', '>= 0.8.3']
  self.extra_dev_deps << ['rspec', '>= 1.2.9']
  self.extra_dev_deps << ['rcov', '>= 0.8.1.2.0']
  self.extra_dev_deps << ['hoe', '>= 2.4.0']
  self.extra_dev_deps << ['diff-lcs', '>= 1.1.2']
  self.extra_dev_deps << ['syntax', '>= 1.0.0']
end

generated_library = File.join('lib', 'rake_dotnet.rb')
CLOBBER.include generated_library
file generated_library do |f|
	files = ['header.rb', 'defaults.rb', 'cli.rb', 'bcpcmd.rb', 'sqlcmd.rb', 'assemblyinfo.rb', 'fxcop.rb', 'harvester.rb', 'msbuild.rb', 'ncover.rb', 'nunitcmd.rb', 'nunittask.rb', 'package.rb', 'sevenzip.rb', 'svn.rb', 'version.rb', 'xunit.rb', 'footer.rb']
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
	t.fail_on_error = true
end

desc "Run all specs with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
	t.spec_files = FileList['spec/**/*.rb']
	t.rcov = true
	t.rcov_opts = ['--exclude', 'spec']
end

task :spec => generated_library
file 'coverage/index.html'  => [:examples_with_rcov]
file 'doc/examples.html'  => [:examples_with_report]

task :package => [:examples_with_report, :examples_with_rcov]

# vim: syntax=Ruby
