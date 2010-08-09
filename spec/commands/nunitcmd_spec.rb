require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NUnitCmd do
	describe 'When no dll is given' do
		it 'should throw' do
			lambda { NUnitCmd.new }.should raise_error(ArgumentError)
		end
	end

	describe 'By default' do
		before :all do
			@cmd = NUnitCmd.new({:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll'})
		end

		it "should have sensible search paths" do
      @cmd.search_paths[0].should match(/#{TOOLS_DIR}\/nunit\/bin\/net-2\.0/)
      @cmd.search_paths[1].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.3/bin/net-2.0")
      @cmd.search_paths[2].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.2/bin/net-2.0")
      @cmd.search_paths[3].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.1/bin/net-2.0")
      @cmd.search_paths[4].should include("#{ENV['PROGRAMFILES']}/nunit 2.5.0/bin/net-2.0")
      @cmd.search_paths[5].should include("#{ENV['PROGRAMFILES']}/nunit/bin/net-2.0")
		end

		it "should use correct exe_name" do
      @cmd.exe.should match(/.*nunit-console-x86.exe/)
		end
		
		it "should read the processor architecture from the environment" do
			@cmd.arch.should == "x86"
		end

		it 'should have no includes specified' do
      @cmd.include.should be_empty
		end

		it 'should have no excludes specified' do
      @cmd.exclude.should be_empty
		end

		it 'should quote the input_file parameter' do
      @cmd.cmd.should match(/\.exe\w*".*dll"/)
		end
	end

	describe 'When told to write a report' do
		before :all do
      @cmd = NUnitCmd.new(:input_files => 'spec/support/nunitcmd/Foo.Unit.Tests.dll',
			                   :options=>{:xml=>true})
		end
		it 'should pick a sensible name for the report' do
      @cmd.cmd.should include('Foo.Unit.Tests.nunit.xml')
		end
		it 'should write xml to a sensible place' do
			file = File.expand_path("#{OUT_DIR}/reports/nunit/Foo.Unit.Tests/Foo.Unit.Tests.nunit.xml")
      @cmd.cmd.should include(file.gsub('/', '\\'))
      @cmd.cmd.should match(/\/xml=".*\.nunit\.xml"/)
		end
		it 'should output a teamcity service message correctly'
	end

	describe 'When told not to write xml' do
		before :all do
			@cmd = NUnitCmd.new(:input_files => 'spec/support/nunitcmd/Foo.Unit.Tests.dll',
			:options=>{:xml=>false})
		end
		it 'should not have /xml=whatever in the command' do
			@cmd.cmd.should_not match(/\/xml=.*\.nunit\.xml/)
		end
	end

	describe 'When includes are specified' do
		before :all do
			@cmd =NUnitCmd.new(:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll',
			:options => {:include=>['unit', 'integration']})
		end
		it 'should use them' do
			@cmd.cmd.should include('/include=')
			@cmd.cmd.should include('unit')
			@cmd.cmd.should include('integration')
		end
	end

	describe 'When excludes are specified' do
		before :all do
			@cmd = NUnitCmd.new(:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll',
			:options => {:exclude=>['integration', 'unit']})
		end
		it 'should use them' do
			@cmd.cmd.should include('/exclude=')
			@cmd.cmd.should include('integration')
			@cmd.cmd.should include('unit')
		end
	end
	
	describe 'When running on x64' do
		before :all do
		  @cmd = NUnitCmd.new({:input_files=>'spec/support/nunitcmd/Foo.Unit.Tests.dll', :arch => "AMD64"})
		end
		it 'should use the specified architecture' do
			@cmd.arch.should == 'AMD64'
		end
		it 'should use correct exe_name' do
			@cmd.exe.should match(/.*nunit-console.exe/)
		end
	end
end
