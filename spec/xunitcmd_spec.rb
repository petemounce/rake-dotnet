require 'spec'
require File.join(File.dirname(__FILE__), '..','lib','cli.rb')
require File.join(File.dirname(__FILE__), '..','lib','xunit.rb')

describe XUnitConsoleCmd do
	it "should have sensible search paths"
	it "should have sensible defaults for all optional settings"
	it "should allow settings to be specified during initialisation"
	it "should require a test_dll"
end
