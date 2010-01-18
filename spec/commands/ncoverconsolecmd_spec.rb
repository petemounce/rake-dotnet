require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverConsoleCmd, 'When initialised with no options' do
	it 'should have sensible search paths'
	it 'should require a assembly to profile'
	it 'should have a default for exclude_assemblies'
	it 'should have a default working directory that is the same dir as the assembly to profile'
	it 'should handle a single string for exclude_assemblies'
	it 'should handle an array for exclude_assemblies'
end
