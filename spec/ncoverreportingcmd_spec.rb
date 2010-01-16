require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cli.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'ncover.rb')

describe NCoverReportingCmd do
	it "should have sensible search paths"
	it "should require a report_dir"
	it "should require coverage files to report against"
	it "should have sensible defaults for reports to generate"
	it "should output into the report directory"
	it "should define a sensible sort order"
	it "should default to a sensible product name"
	it "should include a sensible build_id"
end
