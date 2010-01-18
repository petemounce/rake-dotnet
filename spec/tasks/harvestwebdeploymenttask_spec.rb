require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

describe HarvestWebDeploymentTask, 'When initialised with defaults' do
	before :all do
		@hwdt = HarvestWebDeploymentTask.new
		@harvest_wdps = Rake::Task[:harvest_wdps]
		@harvest = Rake::Task[:harvest]
	end
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	it 'should create a rule to harvest web-deployment project outputs whose name matches conventions'
	it 'should use a sensible directory for output' do
		@hwdt.out_dir.should eql(OUT_DIR)
	end
	it 'should define a task called :harvest_wdps' do
		@harvest_wdps.should_not be_nil
	end
	it ':harvest_wdps should depend on out_dir' do
		@harvest_wdps.prerequisites.should include(OUT_DIR)
	end
	it 'should define a task called :harvest' do
		@harvest.should_not be_nil
	end
	it ':harvest should depend on :harvest_wdps' do
		@harvest.prerequisites.should include('harvest_wdps')
	end
	it ':harvest_wdps not have any dependencies other than out_dir' do
		@harvest_wdps.should have(1).prerequisites
	end
	it 'should look in a sensible place for WDP outputs to harvest' do
		@hwdt.src_dir.should eql(SRC_DIR)
	end
	it 'should have a configuration of Debug' do
		@hwdt.configuration.should eql(CONFIGURATION)
	end
	it 'should harvest everything in the src_dir by default' do
		@hwdt.should have(1).include
		@hwdt.include[0].should eql('*')
	end
end

describe HarvestWebDeploymentTask, 'When given an out_dir' do
	it 'should use it' do
		hwdt = HarvestWebDeploymentTask.new(:out_dir=>'foo')
		hwdt.out_dir.should eql('foo')
	end
end

describe HarvestWebDeploymentTask, 'When given a src_dir' do
	it 'should use it' do
		hwdt = HarvestWebDeploymentTask.new(:src_dir=>'foo')
		hwdt.src_dir.should eql('foo')
	end
end

describe HarvestWebDeploymentTask, 'When given a configuration' do
	it 'should use it' do
		hwdt = HarvestWebDeploymentTask.new(:configuration=>'Release')
		hwdt.configuration.should eql('Release')
	end
end
