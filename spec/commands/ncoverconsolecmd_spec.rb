require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NCoverConsoleCmd do
		before :all do
    @safe_defaults = {:version=>'1.0.0.0', :cmd_to_run => 'nunit.console.exe foo.dll', :dll_to_profile => 'foo.dll'}
		end
  after :all do
    Rake::Task.clear
    Rake::FileTask.clear
  end
  describe 'When initialised with no DLL to profile' do
    it 'should throw' do
      lambda { NCoverConsoleCmd.new :cmd_to_run => 'nunit.console.exe foo.dll' }.should raise_exception(ArgumentError)
    end
  end
  describe 'When initialised with no command to attach the profiler to' do
    it 'should throw' do
      lambda { NCoverConsoleCmd.new :dll_to_profile => 'foo.dll' }.should raise_exception(ArgumentError)
    end
  end
  describe 'When initialised with default settings' do
    before :all do
      @cmd = NCoverConsoleCmd.new(@safe_defaults)
    end
    it 'should read the processor architecture from the environment' do
      @cmd.arch.should == ENV['PROCESSOR_ARCHITECTURE']
    end
    it 'should have sensible search paths' do
      @cmd.search_paths[0].should match(/#{TOOLS_DIR}\/NCover\/#{@cmd.arch}/)
      @cmd.search_paths[1].should include("#{ENV['PROGRAMFILES']}/NCover")
    end
    it 'should use the correct exe_name' do
      @cmd.exe.should match(/ncover\.console\.exe/i)
    end
    it 'should have a default for exclude_assemblies (even if it does not support it because might not be complete version)' do
			@cmd.exclude_assemblies.should include('.*Tests.*')
			@cmd.exclude_assemblies.should include('ISymWrapper')
		end
		it 'should have a default working directory that is the same dir as the assembly to profile' do
			@cmd.cmd.should include('//w "."')
		end
    it 'should not render a service timeout argument' do
			@cmd.cmd.should_not match(/^.*\/\/st \d+.*$/i)
		end
	end
	describe 'When passed exclude_assemblies as a csv string' do
    before :all do
      @cmd = NCoverConsoleCmd.new(@safe_defaults.merge(:exclude_assemblies => 'foo;bar', :is_complete_version => true))
    end
    it 'should correctly render the argument' do
      @cmd.exclude_assemblies_param.should match(/\/\/eas \.\*Tests\.\*;ISymWrapper;foo;bar/)
    end
  end
  describe 'When running on x86' do
    before :all do
      @cmd = NCoverConsoleCmd.new((@safe_defaults.merge :arch => 'x86'))
    end
    it 'should use //reg option on command line' do
      @cmd.cmd.should match(/\/\/reg/)
    end
	end
end
