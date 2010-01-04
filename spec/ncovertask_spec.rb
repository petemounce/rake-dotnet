require 'spec'
require File.join(File.dirname(__FILE__), '..','lib','cli.rb')
require File.join(File.dirname(__FILE__), '..','lib','ncover.rb')

describe NCoverTask do
  it "should default the product_name"
  it "should allow product_name to be specified"
  it "should default bin_dir"
  it "should allow the bin_dir to be specified"
  it "should default the report_dir"
  it "should allow the report_dir to be specified"
  it "should default the dependencies"
  it "should allow the dependencies to be specified"
  it "should default profile_options"
  it "should merge in profile_options that are specified"
  it "should default reporting_options"
  it "should merge in reporting_options that are specified"
  it "should make :ncover_profile depend on each dependency"
  it "should define @report_dir as a directory-task"
  it "should define a rule for ncover_profile"
  it "should define a task for ncover_profile that depends on report_dir"
  it "should define a task for ncover_reports that depends on ncover_profile"
  it "should define :clobber_ncover"
end
