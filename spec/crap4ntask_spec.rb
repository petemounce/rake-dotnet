require 'spec'
require 'rake'
require 'rake/tasklib'
require 'constants_spec.rb'
require File.join(File.dirname(__FILE__), '..', 'lib', 'crap4ncmd.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'crap4ntask.rb')

describe Crap4nTask, 'When initialised with default settings' do
	before :all do
		@c4n = Crap4nTask.new
		@crap4n = Rake::Task[:crap4n]
		@out_dir = File.join(OUT_DIR, 'reports', 'crap4n')
		@analyse = Rake::Task[:analyse]
	end
	after :all do
		Rake::Task.tasks.clear
		Rake::FileTask.tasks.clear
	end
	it 'should have a sensible output directory' do
		@c4n.out_dir.should eql(@out_dir)
	end
	it 'should create a file-task for output directory' do
		Rake::FileTask[@out_dir].should_not be_nil
	end
	it 'should define a task :crap4n' do
		@crap4n.should_not be_nil
	end
	it 'should make :crap4n depend on out_dir' do
		@crap4n.should have(1).prerequisites
		@crap4n.prerequisites.should include(@out_dir)
	end
	it 'should define a task :analyse' do
		@analyse.should_not be_nil
	end
	it 'should make :analyse depend on :crap4n' do
		@analyse.prerequisites.should include('crap4n')
	end
end

describe Crap4nTask, 'When initialised with an out_dir' do
	it 'should use it' do
		c4n = Crap4nTask.new(:out_dir=>'foo')
		c4n.out_dir.should eql('foo')
	end
end