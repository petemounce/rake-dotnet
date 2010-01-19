require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe HarvestWebApplicationTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe HarvestWebApplicationTask, 'When initialised with defaults' do
		before :all do
			@hwat = HarvestWebApplicationTask.new
			@task = Rake::Task[:harvest_webapps]
			@harvest = Rake::Task[:harvest]
		end
		it 'should create a rule to harvest web-applications whose name matches conventions'
		it 'should write output to a sensible place' do
			@hwat.out_dir.should eql(OUT_DIR)
		end
		it 'should define a task called :harvest_webapps' do
			@task.should_not be_nil
		end
		it ':harvest_webapps should depend on out_dir' do
			@task.should have(1).prerequisites
			@task.prerequisites.should include(OUT_DIR)
		end
		it 'should define a task called :harvest' do
			@harvest.should_not be_nil
		end
		it ':harvest should depend on :harvest_webapps' do
			puts @harvest.prerequisites.join(',')
			@harvest.prerequisites.should include('harvest_webapps')
		end
	end
end
