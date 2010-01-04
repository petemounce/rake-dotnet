require 'spec'
require File.join(File.dirname(__FILE__), '..','lib','cli.rb')
require File.join(File.dirname(__FILE__), '..','lib','ncover.rb')

describe NCoverConsoleCmd do
  it "should have sensible search paths"
  it "should require a assembly to profile"
  it "should have a default for exclude_assemblies"
  it "should have a default working directory that's the same dir as the assembly to profile"
  it "should handle a single string for exclude_assemblies"
  it "should handle an array for exclude_assemblies"
end
