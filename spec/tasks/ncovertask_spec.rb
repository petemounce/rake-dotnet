require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with no settings' do
		it 'should have a sensible product_name'
		it 'should default bin_dir'
		it 'should default the report_dir'
		it 'should default the dependencies'
		it 'should default profile_options'
		it 'should default reporting_options'
		it 'should default runner_options'
		it 'should define @report_dir as a directory-task'
		it 'should define a rule for ncover_profile'
		it 'should define a task for ncover_profile that depends on report_dir'
		it 'should define a task for ncover_reports that depends on ncover_profile'
		it 'should define :clobber_ncover'
		it 'should define :ncover'
		it 'should define :analyse'
		it 'should make :analyse depend on :ncover'
	end
	describe 'When initialised with a product name' do
		it 'should use it'
	end
	describe 'When initialised with a bin_dir' do
		it 'should use it'
	end
	describe 'When initialised with a report_dir' do
		it 'should use it'
	end
	describe 'When initialised with dependencies' do
		it 'should use them'
	end
	describe 'When initialised with profile_options' do
		it 'should use them'
	end
	describe 'When initialised with runner_options' do
		it 'should use them'
	end
	describe 'When initialised with reporting_options' do
		it 'should use them'
	end
end
