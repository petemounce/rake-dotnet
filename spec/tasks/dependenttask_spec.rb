require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

describe DependentTask, 'When initialiasing with no main_task_name' do
	it 'should throw ArgumentError' do
		lambda { BlahTask.new }.should raise_error(ArgumentError)
	end
end

class BlahTask < Rake::TaskLib
	include DependentTask
	def initialize(params={})
		super(params)
	end
end

describe DependentTask, 'When initialising with no dependencies' do
	before :all do
		DepTask.new
		@foo = Rake::Task[:foo]
	end
	after :all do
		@foo.clear
	end
	it 'should not make the main-task dependent on anything (else)' do
		@foo.prerequisites[0].should include('dependency1')
		@foo.prerequisites[1].should include('dependency2')
	end
end

describe DependentTask, 'When initialised with some dependencies from an array' do
	before :all do
		@foo = Rake::Task[:foo]
		DepTask.new(:dependencies=>[:a, :b])
	end
	after :all do
		@foo.clear
	end
	it 'should make the main-task dependent on those dependencies' do
		@foo.should have(4).prerequisites
		@foo.prerequisites.should include('dependency1')
		@foo.prerequisites.should include('dependency2')
		@foo.prerequisites.should include('a')
		@foo.prerequisites.should include('b')
	end
end

describe DependentTask, 'When initialised with some dependencies from a CSV string' do
	before :all do
		task :a
		task :b
		@foo = Rake::Task[:foo]
		DepTask.new(:dependencies=>[:a,:b])
	end
	after :all do
		@foo.clear
	end
	it 'should make the main-task dependent on those dependencies' do
		@foo.should have(4).prerequisites
		@foo.prerequisites.should include('dependency1')
		@foo.prerequisites.should include('dependency2')
		@foo.prerequisites.should include('a')
		@foo.prerequisites.should include('b')
	end
end

describe DependentTask, 'When initialised with no dependencies during a CI build' do
	before :all do
		@foo = Rake::Task[:foo]
		DepTask.new(:build_number=>1345)
	end
	after :all do
		@foo.clear
	end
	it 'should not change any dependencies' do
		@foo.should have(2).prerequisites
	end
end

describe DependentTask, 'When initialised with some dependencies during a CI build' do
	before :all do
		task :a
		task :b
		@foo = Rake::Task[:foo]
		DepTask.new(:dependencies=>[:a, :b], :build_number=>1345)
	end
	after :all do
		@foo.clear
	end
	it 'should not make the main-task dependent on those dependencies because dependencies are just sugar for developer builds' do
		@foo.should have(2).prerequisites
	end
end

class DepTask < Rake::TaskLib
	include DependentTask

	def initialize(params={})
		@main_task_name = :foo
		super(params)
		define
	end

	def define
		task :dependency1
		task :dependency2
		task :foo => [:dependency1, :dependency2]
	end
end

