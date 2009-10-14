require 'spec'
require File.join(File.dirname(__FILE__), '..','lib','harvester.rb')

describe HarvestOutputTask do
	it "should use sensible defaults when initialising"
	it "should be possible to set each parameter when initialising"
	it "should define a directory task for @target_path"
	it "should define :harvest_output depending on @target_path"
end
