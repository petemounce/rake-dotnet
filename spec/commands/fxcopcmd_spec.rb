require 'spec'
require 'lib/rake_dotnet.rb'


describe FxCopCmd do
	before :all do
    @safe = {:dlls => [ File.join(Bin_out, 'RakeDotNet.dll') ]}
	end
	describe 'When no DLL is given' do
		it 'should throw' do
			lambda { FxCopCmd.new }.should raise_error(ArgumentError)
		end
	end

  describe 'When initialised with safe default settings' do
		before :all do
      @cmd = FxCopCmd.new(@safe)
    end
    it 'should have sensible search paths' do
      @cmd.search_paths[0].should match(/#{TOOLS_DIR}\/fxcop/i)
      @cmd.search_paths[1].should include("#{ENV['PROGRAMFILES']}/Microsoft FxCop 1.36")
      @cmd.search_paths[2].should include("#{ENV['PROGRAMFILES']}/Microsoft FxCop")
    end
    it 'should not use console' do

		end
	end

	describe 'When told to use applyoutxsl' do
		it 'should do so' do
      cmd = FxCopCmd.new(@safe.merge(:apply_out_xsl=>true))
			cmd.cmd.should include('/applyoutxsl')
		end
	end

	describe 'When told to use console' do
    before :all do
      @cmd = FxCopCmd.new(@safe.merge(:echo_to_console=>true))
    end
    it 'should do so' do
      @cmd.cmd.should include('/console')
    end
	end

	describe 'When given an out_file' do
    before :all do
      @cmd = FxCopCmd.new(@safe.merge(:out_file=>'foo.xml'))
    end
    it 'should use it' do
      @cmd.cmd.should include("/out:\"foo.xml\"")
    end
	end
end
