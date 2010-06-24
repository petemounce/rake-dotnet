require 'rake'
require 'rake/clean'

CONFIGURATION = ENV['CONFIGURATION'] || 'Debug'

CLEAN.include('*.a')
CLEAN.include('*.b')

rule ".a" do |r|
	sh "touch #{r.name}"
	puts "built #{r.name}"
end

rule /.*\.b/ do |r|
	sh "touch #{r.name}"
	puts "built #{r.name}"
end

file 'something.b' => ['foo.a', 'bar.a']

task :default => 'something.b'
