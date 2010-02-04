require 'spec'
require 'lib/rake_dotnet.rb'

describe NCoverTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with no settings' do
		before :all do
			@task = NCoverTask.new
			@report_dir = File.join(OUT_DIR,'reports','ncover')
			@report_dir_task = Rake::FileTask[@report_dir]
			@clobber_ncover_task = Rake::Task[:clobber_ncover]
			@ncover_task = Rake::FileTask[:ncover]
			@coverage_task = Rake::FileTask[:coverage]
		end
		it_should_behave_like 'A DependentTask'
		it 'should have a sensible product_name' do
			@task.product_name.should eql(PRODUCT_NAME)
		end
		it 'should default bin_dir' do
			@task.bin_dir.should eql(File.join(OUT_DIR, 'bin'))
		end
		it 'should default the report_dir' do
			@task.report_dir.should eql(@report_dir)
		end
		it 'should default the dependencies' do
			@task.dependencies.should be_empty
		end
		it 'should default profile_options' do
			@task.profile_options[:arch].should_not be_nil 
		end
		it 'should default reporting_options' do
			@task.reporting_options[:arch].should_not be_nil
		end
		it 'should default runner_options' do
			@task.runner_options[:xml].should eql(false)
		end
		it 'should default merge options' do
			@task.merge_options[:arch].should_not be_nil
		end
		it 'should define report_dir as a directory-task' do
			@report_dir_task.should_not be_nil
		end
		it 'should define a rule for ncover_profile'
		it 'should define a task for ncover_profile that depends on report_dir'
		it 'should define a task for ncover_reports that depends on ncover_profile'
		it 'should define :clobber_ncover' do
			@clobber_ncover_task.should_not be_nil
		end
		it 'should define :ncover' do
			@ncover_task.should_not be_nil
		end
		it 'should define :coverage' do
			@coverage_task.should_not be_nil
		end
		it 'should make :coverage depend on :ncover' do
			@coverage_task.prerequisites.should include('ncover')
		end
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
