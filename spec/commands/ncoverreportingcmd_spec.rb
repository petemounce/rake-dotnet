require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NCoverReportingCmd do
  before :all do
    @safe = {:arch => 'x86', :coverage_files => ['foo.coverage.xml'], :version => '1.2'}
  end
  describe 'When initialised with no coverage files to run against' do
    it 'should throw' do
      lambda { NCoverReportingCmd.new(:arch=>'x86') }.should raise_error(ArgumentError)
    end
  end
	describe 'When initialised with default settings' do
		before :all do
      @cmd = NCoverReportingCmd.new(@safe)
    end
    it 'should have sensible search paths' do
      @cmd.search_paths[0].should match(/#{TOOLS_DIR}\/NCover\/#{@safe[:arch]}/)
      @cmd.search_paths[1].should include("#{ENV['PROGRAMFILES']}/NCover")
    end
    it 'should call ncover.reporting.exe' do
      @cmd.cmd.should match(/ncover\.reporting\.exe/i)
		end
		it 'should have sensible defaults for reports to generate' do
      @cmd.cmd.should match(/\/\/or Summary/)
		end
    it 'should output into the correct directory' do
      op = File.expand_path(File.join(OUT_DIR, 'reports', 'ncover', 'foo')).gsub('/', '\\')
      @cmd.cmd.should include("//op \"#{op}\"")
		end
		it 'should define a sensible sort order' do
      @cmd.cmd.should match(/\/\/so CoveragePercentageAscending/)
		end
		it 'should default to a sensible project name' do
      @cmd.cmd.should match(/\/\/p #{PRODUCT_NAME}/)
		end
		it 'should include a sensible build_id' do
      @cmd.cmd.should match(/\/\/bi #{re(@safe[:version])}/)
		end
		it 'should not use a specific save_to because ncover does a sensible thing when just report_dir is given' do
      @cmd.cmd.should_not include('//s ')
    end
  end
  describe 'When we have the complete-version and we give it some complete-version-only reports' do
    before :all do
      @cmd = NCoverReportingCmd.new(@safe.merge(:is_complete_version=>true))
    end
    it 'should render them into the command' do
      @cmd.cmd.should match(/\/\/or UncoveredCodeSections/)
      @cmd.cmd.should match(/\/\/or FullCoverageReport/)
    end
  end
  describe 'When we have the regular version and we give it some complete-version-only reports' do
    before :all do
      @cmd = NCoverReportingCmd.new(@safe.merge(:is_complete_version=>false))
    end
    it 'should only render reports that are allowed' do
      @cmd.cmd.should match(/\/\/or Summary[ ]+\/\/op/)
		end
	end
end
