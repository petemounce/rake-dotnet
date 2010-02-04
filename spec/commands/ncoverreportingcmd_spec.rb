require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverReportingCmd do
	describe 'When initialised with default settings' do
		before :all do
			@cmd = NCoverReportingCmd.new(File.join(OUT_DIR, 'reports', 'ncover', 'foo'), [], {})
		end
		it 'should have sensible search paths'
		it 'should require a report_dir'
		it 'should require coverage files to report against'
		it 'should have sensible defaults for reports to generate' do
			@cmd.reports.should include('Summary')
			@cmd.reports.should include('UncoveredCodeSections')
			@cmd.reports.should include('FullCoverageReport')
		end
		it 'should output into the report directory' do
			@cmd.report_dir.should eql(File.join(OUT_DIR, 'reports', 'ncover', 'foo'))
		end
		it 'should define a sensible sort order' do
			@cmd.sort_order.should eql('//so CoveragePercentageAscending')
		end
		it 'should default to a sensible project name' do
			@cmd.project_name.should eql("//p #{PRODUCT_NAME}")
		end
		it 'should include a sensible build_id' do
			#TODO: Invert dependency
			@cmd.build_id.should eql("//bi #{Versioner.new.get}")
		end
		it 'should not use a specific save_to because ncover does a sensible thing when just report_dir is given' do
			@cmd.save_to.should be_nil
		end
	end
end
