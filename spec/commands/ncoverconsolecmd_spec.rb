require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverConsoleCmd do
	describe 'When initialised with no options' do
		before :all do
			@cmd = NCoverConsoleCmd.new('foo', 'bar.dll', {:cmd_to_run=>''})
		end
		it 'should have sensible search paths'
		it 'should require a assembly to profile'
		it 'should have a default for exclude_assemblies (even if it does not support it because might not be complete version' do
			@cmd.exclude_assemblies.should include('.*Tests.*')
			@cmd.exclude_assemblies.should include('ISymWrapper')
		end
		it 'should have a default working directory that is the same dir as the assembly to profile' do
			@cmd.cmd.should include('//w "."')
		end
		it 'should spit out //reg option when running on x86'
		it 'should not spit out a service timeout argument' do
			@cmd.cmd.should_not match(/^.*\/\/st \d+.*$/i)
		end
	end
	describe 'When passed exclude_assemblies as a csv string' do
		it 'should output the correct command line'
	end
end
