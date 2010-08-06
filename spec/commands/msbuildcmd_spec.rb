require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe MsBuildCmd do
  before :all do
    @safe = {:project => 'foo.csproj'}
  end
  describe 'When initialised without a project' do
    it 'should throw' do
      lambda { MsBuildCmd.new }.should raise_error(ArgumentError, /:project/)
    end
  end
  describe 'When initialised with default settings' do
    before :all do
      @cmd = MsBuildCmd.new(@safe)
    end
    it 'should have sensible search paths' do
      @cmd.search_paths[0].should include("#{ENV['windir']}/Microsoft.NET/Framework/v4.0")
      @cmd.search_paths[1].should include("#{ENV['windir']}/Microsoft.NET/Framework/v3.5")
      @cmd.search_paths[2].should include("#{ENV['windir']}/Microsoft.NET/Framework/v2.0.50727")
    end
    it 'should have the correct :exe_name' do
      @cmd.cmd.should match(/msbuild\.exe/i)
    end
    it 'should try to use as many CPUs as possible' do
      @cmd.cmd.should match(/\/maxcpucount/)
    end
    it 'should render the path to the project (in quotes) after the exe' do
      @cmd.cmd.should match(/msbuild\.exe" ".*\\foo.csproj"/i)
    end
    it 'should render the verbosity argument' do
      @cmd.cmd.should match(/\/v:n/)
    end
    it 'should render no properties' do
      @cmd.cmd.should_not match(/\/p:/)
    end
    it 'should render no targets' do
      @cmd.cmd.should_not match(/\/t:/)
    end
  end
  describe 'When given a verbosity' do
    it 'should use it' do
      MsBuildCmd.new(@safe.merge(:verbosity => 'm')).cmd.should match(/\/v:m/)
    end
  end
  describe 'When given a property' do
    it 'should render it' do
      MsBuildCmd.new(@safe.merge(:properties => {:foo => 'bar'})).cmd.should match(/\/p:foo=bar/)
    end
  end
  describe 'When given more than one property' do
    it 'should render all of them' do
	  test_fudge = {:moo => 'oom'}
      MsBuildCmd.new(@safe.merge(:properties => {:foo => 'bar', :wibble => 'oops'})).cmd.should match(/\/p:foo=bar;wibble=oops/)
    end
  end
  describe 'When given a target' do
    it 'should render it' do
      MsBuildCmd.new(@safe.merge(:targets => ['foo'])).cmd.should match(/\/t:foo/)
    end
  end
  describe 'When given more than one target' do
    it 'should render all of them' do
      MsBuildCmd.new(@safe.merge(:targets => ['foo', 'bar'])).cmd.should match(/\/t:foo;bar/)
    end
  end
end
