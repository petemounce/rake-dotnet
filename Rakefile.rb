# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'Pathname'
require 'rake/clean'

Hoe.new('rake-dotnet', '0.1.8') do |p|
  p.author = 'Peter Mounce'
  p.description = 'Making a .NET build-automation dev\'s life easier, one angle-bracket at a time'
  p.email = 'pete@neverrunwithscissors.com'
  p.summary = 'Build automation for .NET builds'
  p.rubyforge_name = 'rake-dotnet' # if different than lowercase project name
  p.developer('Peter Mounce', 'pete@neverrunwithscissors.com')
  p.remote_rdoc_dir = ''
  p.extra_deps = ['rake']
  p.url = 'http://blog.neverrunwithscissors.com/tag/rake-dotnet'
end

generated_library = File.join('lib','rake_dotnet.rb')
CLOBBER.include generated_library
file generated_library do |f|
	text = ''
	files = ['header.rb','defaults.rb','assemblyinfo.rb','fxcop.rb','harvester.rb','msbuild.rb','ncover.rb','package.rb','sevenzip.rb','svn.rb','version.rb','xunit.rb']
	gl = File.open(generated_library, 'a')
	files.each do |file|
		text = File.read(File.join('lib', file))
		gl.puts text
		gl.puts
		gl.puts
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

# vim: syntax=Ruby
