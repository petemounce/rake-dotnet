require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverConsoleCmd do
	describe 'When initialised with no options' do
		before :all do
			@cmd = NCoverConsoleCmd.new('foo', 'bar.dll', {:cmd_to_run=>''})
		end
		it 'should have sensible search paths'
		it 'should require a assembly to profile'
		it 'should have a default for exclude_assemblies'
		it 'should have a default working directory that is the same dir as the assembly to profile'
		it 'should handle a single string for exclude_assemblies'
		it 'should handle an array for exclude_assemblies'
		it 'should spit out //reg option when running on x86'
		it 'should not spit out a service timeout argument' do
			@cmd.cmd.should_not match(/^.*\/\/st \d+.*$/i)
		end
	end
end
