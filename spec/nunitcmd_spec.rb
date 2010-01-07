require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cli.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nunitcmd.rb')
require 'constants_spec.rb'

describe NUnitCmd, 'When no dll is given' do
	it 'should throw' do
		lambda { NUnitCmd.new }.should raise_error(ArgumentError)
	end
end

describe NUnitCmd, 'By default' do
	attr_accessor :nc
	before :all do
		@nc = NUnitCmd.new({:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll'})
	end

	it "should have sensible search paths" do
		@nc.search_paths[0].should match(/#{TOOLS_DIR}\/nunit\/bin\/net-2\.0/)
		@nc.search_paths[1].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.3/bin/net-2.0")
		@nc.search_paths[2].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.2/bin/net-2.0")
		@nc.search_paths[3].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.1/bin/net-2.0")
		@nc.search_paths[4].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.0/bin/net-2.0")
		@nc.search_paths[5].should include("#{ENV['PROGRAMFILES']}/nunit/bin/net-2.0")
	end

	it "should use correct exe_name" do
		@nc.exe.should match(/.*nunit-console.exe/)
	end

	it 'should write xml to a sensible place' do
		file = File.expand_path("#{OUT_DIR}/reports/nunit/Foo.Unit.Tests.nunit.xml")
		@nc.cmd.should include(file.gsub('/', '\\'))
	end

	it 'should pick a sensible name for the report' do
		@nc.cmd.should include('Foo.Unit.Tests.nunit.xml')
	end
end
