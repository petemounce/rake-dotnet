# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'Pathname'
require 'rake'
require 'rake/clean'

Hoe.spec 'rake-dotnet' do
	developer('Peter Mounce', 'public@neverrunwithscissors.com')
	self.summary = 'A collection of custom-tasks to make a .NET project easily buildable via command-line automation'
	self.description = 'Removing angle brackets from a .NET build-guy\'s life one at a time...'
	#self.homepage = 'http://github.com/petemounce/rake-dotnet'
	self.version = '0.2.0'
	self.extra_deps << ['rake', '>= 0.8.3']
	self.extra_dev_deps << ['rspec', '>= 1.2.9']
	self.extra_dev_deps << ['rcov', '>= 0.8.1.2.0']
	self.extra_dev_deps << ['hoe', '>= 2.4.0']
	self.extra_dev_deps << ['diff-lcs', '>= 1.1.2']
	self.extra_dev_deps << ['syntax', '>= 1.0.0']
end

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

file 'coverage/index.html' => [:examples_with_rcov]
file 'doc/examples.html' => [:examples_with_report]

task :package => [:examples_with_report, :examples_with_rcov]

# vim: syntax=Ruby
