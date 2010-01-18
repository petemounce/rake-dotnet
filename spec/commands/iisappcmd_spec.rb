require 'spec'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

describe IisAppCmd do
	it "should have some sensible default paths to look for exe"
	it "should require a physical path"
	it "should default to http://*:80 when no bindings are supplied"
	it "should handle a list of bindings"
	it "should handle a single binding"
	it "should default to naming the site like the last directory name in physical-path"
	it "should use a supplied website name"
	it "should use a supplied id"
	it "should generate an id when not supplied"
end
