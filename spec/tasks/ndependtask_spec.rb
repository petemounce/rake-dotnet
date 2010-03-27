require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NDependTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with no settings' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = NDependTask.new
			@ndepend = Rake::Task[:ndepend]
			@out_dir = File.join(OUT_DIR, 'reports', 'ndepend')
			@reports_dir = Rake::FileTask[@out_dir]
			@clobber_ndepend = Rake::Task[:clobber_ndepend]
		end

		it 'should pass reports_dir to options for console runner' do
			@task.options.should include(:out_dir)
			@task.out_dir.should eql(@task.options[:out_dir])
		end
		it 'should define a directory for reports' do
			@reports_dir.should_not be_nil
			@reports_dir.should be_a(Rake::FileTask)
			@reports_dir.name.should eql(@out_dir)
		end
		it 'should define an :ndepend task' do
			@ndepend.should_not be_nil
			@ndepend.should be_a(Rake::Task)
		end
		it 'should make :ndepend depend on @reports_dir' do
			@ndepend.prerequisites.should include(@out_dir)
		end
		it 'should define a :clobber_ndepend task' do
			@clobber_ndepend.should_not be_nil
			@clobber_ndepend.should be_a(Rake::Task)
		end
		it 'should use a sensible glob for finding assemblies in the binaries directory' do
			@task.globs.should include("#{Bin_out}/**/#{PRODUCT_NAME}*.dll")
		end
	end

	describe 'When initialised with reports_dir specified' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = NDependTask.new(:out_dir=>'foo')
		end
		it 'should use it' do
			@task.out_dir.should eql('foo')
		end
	end

	describe 'When initialised with dependencies' do
		it_should_behave_like 'A DependentTask'
		before :all do
			@task = NDependTask.new(:dependencies=>[:foo], :build_number=>0)
			@ndepend = Rake::Task[:ndepend]
		end
		it 'should make :ndepend task depend on those' do
			@ndepend.prerequisites.should include('foo')
		end
	end
end
