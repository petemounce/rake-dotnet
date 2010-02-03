require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe HarvestOutputTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end

	describe 'When initialised with defaults' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = HarvestOutputTask.new
			@harvest_output = Rake::Task[:harvest_output]
			@harvest = Rake::Task[:harvest]
		end
		it 'should have a sensible src_dir' do
			@task.src_dir.should eql(File.join(PRODUCT_ROOT, 'src'))
		end
		it 'should have a sensible out_dir' do
			@task.out_dir.should eql(Bin_out)
		end
		it 'should have a sensible configuration' do
			@task.configuration.should eql(CONFIGURATION)
		end
		it 'should have a sensible set of globs to choose to harvest from' do
			@task.should have(1).glob
			@task.glob.should include("#{@task.src_dir}/*")
		end
		it 'should define a directory task for out_dir' do
			Rake::FileTask[Bin_out].should_not be_nil
		end
		it 'should define a task called :harvest_output' do
			@harvest_output.should_not be_nil
		end
		it 'should make :harvest_output depend on out_dir' do
			@harvest_output.prerequisites.should include(Bin_out)
		end
		it 'should not make :harvest_output depend on anything else' do
			@harvest_output.should have(1).prerequisites
		end
		it 'should define a task called :harvest' do
			@harvest.should_not be_nil
		end
		it 'should make :harvest depend on :harvest_output' do
			@harvest.should have(1).prerequisites
			@harvest.prerequisites.should include('harvest_output')
		end
	end

	describe 'When initialised with a dependency' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = HarvestOutputTask.new(:dependencies=>[:foo])
			@harvest_output = Rake::Task[:harvest_output]
		end
		it 'should read those dependencies' do
			@task.dependencies.should include(:foo)
		end
		it 'should make :harvest_output depend on that' do
			@harvest_output.should have(2).prerequisites
			@harvest_output.prerequisites.should include('foo')
		end
	end
end
