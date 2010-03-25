require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

shared_examples_for 'A DependentTask' do
	it 'should have a dependencies accessor' do
		@task.should respond_to(:dependencies)
	end
	it 'should have a ci_dependencies accessor' do
		@task.should respond_to(:ci_dependencies)
	end
	it 'should make the main-task dependent on the dependencies passed when it is a local build' do
		@task.dependencies.each do |d|
			Rake::Task[@task.main_task_name].prerequisites.should include(d.to_s)
		end
	end
	it 'should make the main-task dependent on the ci_dependencies passed when it is not a local build' do
		@task.ci_dependencies.each do |d|
			@task.is_local_build = false
			Rake::Task[@task.main_task_name].prerequisites.should include(d.to_s)
		end
	end
end

describe DependentTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialiasing with no main_task_name' do
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

	describe 'When initialising with no dependencies' do
		before :all do
			DepTask.new
			@foo = Rake::Task[:foo]
		end
		it 'should not make the main-task dependent on anything (else)' do
			@foo.prerequisites[0].should include('dependency1')
			@foo.prerequisites[1].should include('dependency2')
		end
	end

	describe 'When initialised with some dependencies from an array' do
		before :all do
			task :foo
			@foo = Rake::Task[:foo]
			DepTask.new(:dependencies=>[:a, :b])
		end
		it 'should make the main-task dependent on those dependencies' do
			@foo.should have(4).prerequisites
			@foo.prerequisites.should include('dependency1')
			@foo.prerequisites.should include('dependency2')
			@foo.prerequisites.should include('a')
			@foo.prerequisites.should include('b')
		end
	end

	describe 'When initialised with some dependencies from a CSV string' do
		before :all do
			task :a
			task :b
			task :foo
			@foo = Rake::Task[:foo]
			DepTask.new(:dependencies=>'a,b')
		end
		it 'should make the main-task dependent on those dependencies' do
			@foo.should have(4).prerequisites
			@foo.prerequisites.should include('dependency1')
			@foo.prerequisites.should include('dependency2')
			@foo.prerequisites.should include('a')
			@foo.prerequisites.should include('b')
		end
	end

	describe 'When initialised with no dependencies during a CI build' do
		before :all do
			task :foo
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

	describe 'When initialised with some dependencies during a CI build' do
		before :all do
			puts 'start'
			task :a
			task :b
			task :foo
			DepTask.new(:dependencies=>[:a, :b], :build_number=>1345)
			@foo = Rake::Task[:foo]
		end
		after :all do
			@foo.clear
		end
		it 'should not make the main-task dependent on those dependencies because dependencies are just sugar for developer builds' do
			@foo.prerequisites.should_not include('a')
			@foo.prerequisites.should_not include('b')
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

end
