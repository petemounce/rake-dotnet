require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NUnitTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with no settings' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = NUnitTask.new
			@out_dir = File.join(OUT_DIR, 'reports', 'nunit')
			@nunit = Rake::Task[:nunit]
		end
		it 'should have a sensible suites directory to look in' do
			sd = File.join(OUT_DIR, 'bin')
			@task.suites_dir.should match(/#{re(sd)}/)
		end
		it 'should have a sensible reports directory to write to' do
			@task.out_dir.should match(/#{re(@out_dir)}/)
		end
		it 'should have no dependencies set' do
			@task.dependencies.should be_empty
		end
		it 'should create a directory for the reports' do
			rd = Rake::FileTask[@out_dir]
			rd.should_not be_nil
			rd.should be_a(Rake::FileTask)
			rd.name.should eql(@out_dir)
		end
		it 'should create a task called :nunit' do
			@nunit.should_not be_nil
			@nunit.should be_a(Rake::Task)
			@nunit.name.should eql('nunit')
		end
		it 'should make :nunit depend on @reports_dir' do
			@nunit.prerequisites.should include(@out_dir)
		end
		it 'should create a task to clobber the nunit-output' do
			cn = Rake::Task[:clobber_nunit]
			cn.should_not be_nil
		end
		it 'should create a rule matching the reports directory that will be hit by the suite to run'
	end

	describe 'When initialised with suites dir' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@sd = File.join(OUT_DIR, 'bong')
			@task = NUnitTask.new(:suites_dir=>@sd)
		end
		it 'should use that dir' do
			@task.suites_dir.should match(/#{re(@sd)}/)
		end
	end

	describe 'When initialised with out_dir' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@d = File.join(OUT_DIR, 'junk')
			@task = NUnitTask.new(:out_dir => @d)
		end
		it 'should use that dir' do
			@task.out_dir.should match(/#{re(@d)}/)
		end
	end

	describe 'When initialised with runner options' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = NUnitTask.new(:runner_options => {:exclude=>'unit,integration'})
		end
		it 'should use those options' do
			@task.runner_options.should_not be_empty
		end
	end

	describe NUnitTask, 'When initialised with dependencies' do
		it_should_behave_like 'A DependentTask'
		before :all do
			task :foo
			@task = NUnitTask.new(:dependencies=>[:foo])
			@nunit = Rake::Task[:nunit]
		end
		it 'should create :nunit task' do
			@nunit.should_not be_nil
			@nunit.should be_a(Rake::Task)
			@nunit.name.should eql('nunit')
		end
		it 'should read those dependencies' do
			@task.dependencies.should include(:foo)
		end
		it 'should create :nunit task that depends on those' do
			@nunit.prerequisites.should include('foo')
		end
	end
end
