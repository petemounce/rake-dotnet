require 'spec'
require 'lib/rake_dotnet.rb'


describe FxCopCmd do
	before :all do
		@dlls = [].push File.join(Bin_out, 'RakeDotNet.dll')
	end
	describe 'When no DLL is given' do
		it 'should throw' do
			lambda { FxCopCmd.new }.should raise_error(ArgumentError)
		end
	end

	describe 'When initialised with default settings plus a DLL' do
		before :all do
			@fx = FxCopCmd.new(@dlls, {})
		end
		it 'should have sensible search paths'
		it 'should not use console'
	end

	describe 'When told to use applyoutxsl' do
		it 'should do so' do
			cmd = FxCopCmd.new(@dlls, :apply_out_xsl=>true)
			cmd.cmd.should include('/applyoutxsl')
		end
	end

	describe 'When told to use console' do
		it 'should do so' # do
		#FxCopCmd.new(:echo_to_console=>true).cmd.should include('/console')
		#end
	end

	describe 'When given an out_file' do
		it 'should use it' #do
		#FxCopCmd.new(:out_file=>'foo.xml').cmd.should include("/out:\"foo.xml\"")
		#end
	end
end
