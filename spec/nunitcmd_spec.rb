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

	it 'should have no includes specified' do
		@nc.include.should be_empty
	end

	it 'should have no excludes specified' do
		@nc.exclude.should be_empty
	end

	it 'should quote the input_file parameter' do
		@nc.cmd.should match(/\.exe\w*".*dll"/)
	end
end

describe NUnitCmd, 'When told to write a report' do
	before :all do
		@nc = NUnitCmd.new(:input_files => 'spec/support/nunitcmd/Foo.Unit.Tests.dll',
		                   :options=>{:xml=>true})
	end
	it 'should pick a sensible name for the report' do
		@nc.cmd.should include('Foo.Unit.Tests.nunit.xml')
	end
	it 'should write xml to a sensible place' do
		file = File.expand_path("#{OUT_DIR}/reports/nunit/Foo.Unit.Tests/Foo.Unit.Tests.nunit.xml")
		@nc.cmd.should include(file.gsub('/', '\\'))
		@nc.cmd.should match(/\/xml=".*\.nunit\.xml"/)
	end
	it 'should output a teamcity service message correctly'
end

describe NUnitCmd, 'When told not to write xml' do
	it 'should not have /xml=whatever in the command' do
		nc = NUnitCmd.new(:input_files => 'spec/support/nunitcmd/Foo.Unit.Tests.dll',
		                  :options=>{:xml=>false})
		nc.cmd.should_not match(/\/xml=.*\.nunit\.xml/)
	end
end

describe NUnitCmd, 'When includes are specified' do
	it 'should use them' do
		nc = NUnitCmd.new(:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll',
		                  :options => {:include=>['unit', 'integration']})
		nc.cmd.should include('/include=')
		nc.cmd.should include('unit')
		nc.cmd.should include('integration')
	end
end

describe NUnitCmd, 'When excludes are specified' do
	it 'should use them' do
		nc = NUnitCmd.new(:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll',
		                  :options => {:exclude=>['integration', 'unit']})
		nc.cmd.should include('/exclude=')
		nc.cmd.should include('integration')
		nc.cmd.should include('unit')
	end
end
