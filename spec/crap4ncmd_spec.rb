require 'spec'
require 'constants_spec.rb'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cli.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'crap4ncmd.rb')

describe Crap4nCmd, 'When initialised with no name set' do
	it 'should throw' do
		lambda { Crap4nCmd.new }.should raise_error(ArgumentError)
	end
end

describe Crap4nCmd, 'When initialised with a name' do
	before :all do
		@cmd = Crap4nCmd.new(:name=>'RakeDotNet.Unit.Tests')
	end
	it 'should have sensible search_paths' do
		@cmd.search_paths[0].should match(/#{TOOLS_DIR}\/crap4n/)
		@cmd.search_paths[1].should be_nil
	end
	it 'should have a correct exe_name' do
		@cmd.cmd.should match(/.*crap4n-console\.exe.*/)
	end
	it 'should use a sensible coverage file' do
		cc = File.expand_path(File.join(OUT_DIR, 'reports', 'ncover', 'RakeDotNet.Unit.Tests', 'RakeDotNet.Unit.Tests.coverage.xml')).gsub('/','\\')
		@cmd.cmd.should include("/cc=\"#{cc}\"")
	end
	it 'should use a sensible code metrics file' do
		cm = File.expand_path(File.join(OUT_DIR, 'reports', 'ncover', 'RakeDotNet.Unit.Tests', 'RakeDotNet.Unit.Tests.coverage.xml')).gsub('/','\\')
		@cmd.cmd.should include("/cm=\"#{cm}\"")
	end
	it 'should use a sensible xml output file' do
		xml = File.expand_path(File.join(OUT_DIR, 'reports', 'crap4n', 'RakeDotNet.Unit.Tests.crap4n.xml')).gsub('/','\\')
		@cmd.cmd.should include("/xml=\"#{xml}\"")
	end
end


#crap4n-console.exe /cc=partcoverfile.xml /cm=sourcemonitorfile.xml
#
#other options for the console runner:
#/c=10 - which crap level cutoff to use, default is 30
#/xml=output.xml - store the result as xml instead of print it to the console