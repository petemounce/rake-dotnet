require 'spec'
require 'rake'
require 'rake/tasklib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'helpers.rb')
require 'constants_spec.rb'

require File.join(File.dirname(__FILE__), '..', 'lib', 'dependenttask.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'harvestoutputtask.rb')

describe HarvestOutputTask, 'When initialised with defaults' do
	before :all do
		@hot = HarvestOutputTask.new
		@task = Rake::Task[:harvest_output]
		@harvest = Rake::Task[:harvest]
	end
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	it 'should have a sensible src_dir' do
		@hot.src_dir.should eql(File.join(PRODUCT_ROOT, 'src'))
	end
	it 'should have a sensible out_dir' do
		@hot.out_dir.should eql(Bin_out)
	end
	it 'should have a sensible configuration' do
		@hot.configuration.should eql(CONFIGURATION)
	end
	it 'should have a sensible set of globs to choose to harvest from' do
		@hot.should have(1).glob
		@hot.glob.should include("#{@hot.src_dir}/*")
	end
	it 'should define a directory task for out_dir' do
		Rake::FileTask['out/bin'].should_not be_nil
	end
	it 'should define a task called :harvest_output' do
		@task.should_not be_nil
	end
	it 'should make :harvest_output depend on out_dir' do
		@task.prerequisites.should include('out/bin')
	end
	it 'should not make :harvest_output depend on anything else' do
		@task.should have(1).prerequisites
	end
	it 'should define a task called :harvest' do
		@harvest.should_not be_nil
	end
	it 'should make :harvest depend on :harvest_output' do
		@harvest.should have(1).prerequisites
		@harvest.prerequisites.should include('harvest_output')
	end
end

describe HarvestOutputTask, 'When initialised with a dependency' do
	before :all do
		@hot = HarvestOutputTask.new(:dependencies=>[:foo])
		@task = Rake::Task[:harvest_output]
	end
	it 'should read those dependencies' do
		@hot.dependencies.should include(:foo)
	end
	it 'should make :harvest_output depend on that' do
		@task.should have(2).prerequisites
		@task.prerequisites.should include('foo')
	end
end
