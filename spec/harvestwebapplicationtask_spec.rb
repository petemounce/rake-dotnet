require 'spec'
require 'rake'
require 'rake/tasklib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'helpers.rb')
require 'constants_spec.rb'

require File.join(File.dirname(__FILE__), '..', 'lib', 'dependenttask.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'harvestwebapplicationtask.rb')

describe HarvestWebApplicationTask, 'When initialised with defaults' do
	before :all do
		@hwat = HarvestWebApplicationTask.new
		@task = Rake::Task[:harvest_webapps]
	end
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
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
end
