require 'rake'
require 'rake/clean'
require 'xunit.rb'

CONFIGURATION = ENV['CONFIGURATION'] || 'Debug'
VERBOSE = ENV['VERBOSE'] || false
TOOLS_DIR = File.join('..', 'DemoRoot', '3rdparty')

verbose(VERBOSE)

msbuild = File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe')
solution = File.join('..', 'DemoRoot', 'Demo', 'Demo.sln')

CLOBBER.include('../DemoRoot/Demo/**/bin')
CLOBBER.include('../DemoRoot/Demo/**/obj')
CLOBBER.include('*.html')

task :build do
	sh "#{msbuild} /v:m /t:Build /p:Configuration=#{CONFIGURATION} #{solution}"
end

report_dir = File.join('out')
directory report_dir
CLOBBER.include('out')

task :xunit => [:build, report_dir] do
	test_dll = File.join('..', 'DemoRoot', 'Demo', 'src', 'Demo.Unit.Tests', 'bin', CONFIGURATION, 'Demo.Unit.Tests.dll')
	x = XUnit.new(test_dll, report_dir, nil, options={:html=>true})
	x.run
end

task :default => [:build, :xunit]
