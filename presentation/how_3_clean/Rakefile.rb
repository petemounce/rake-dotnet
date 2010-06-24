require 'rake'
require 'rake/clean'

CONFIGURATION = ENV['CONFIGURATION'] || 'Debug'

msbuild = File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe')
solution = File.join('..', 'DemoRoot', 'Demo', 'Demo.sln')

foo = 'foo.intermediate'
bar = 'bar.end_result'
baz = 'baz.end_result'
uber = 'uber.end_result'

file foo do
	puts 'building foo'
	sh "touch #{foo}"
end

file bar => [foo] do
	puts 'building bar'
	sh "touch #{bar}"
end

file baz => [foo] do
	puts 'building baz'
	sh "touch #{baz}"
end

file uber => [bar, baz] do
	puts 'building ze uber output'
	sh "touch #{uber}"
end

CLEAN.include('foo.intermediate')
CLOBBER.include('*.end_result')
CLOBBER.include('../DemoRoot/Demo/**/bin')
CLOBBER.include('../DemoRoot/Demo/**/obj')

task :build => [uber] do
	sh "#{msbuild} /v:m /t:Build /p:Configuration=#{CONFIGURATION} #{solution}"
end

task :default => [:build]
