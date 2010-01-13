require 'spec'
require 'rake'
require 'rake/tasklib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'dependenttask.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nunittask.rb')
require 'constants_spec.rb'

describe NUnitTask, 'When initialised with no settings' do
	before :all do
		@nut = NUnitTask.new
	end
	it 'should have a sensible suites directory to look in' do
		sd = File.join(OUT_DIR, 'bin')
		@nut.suites_dir.should match(/#{re(sd)}/)
	end
	it 'should have a sensible reports directory to write to' do
		d = File.join(OUT_DIR, 'reports', 'nunit')
		@nut.out_dir.should match(/#{re(d)}/)
	end
	it 'should have no nunit runner options set' do
		@nut.runner_options.should be_empty
	end
	it 'should have no dependencies set' do
		@nut.dependencies.should be_empty
	end
	it 'should create a directory for the reports' do
		rd = Rake::FileTask['out/reports/nunit']
		rd.should_not be_nil
		rd.should be_a(Rake::FileTask)
		rd.name.should eql('out/reports/nunit')
	end
	it 'should create a task called :nunit' do
		nunit = Rake::Task[:nunit]
		nunit.should_not be_nil
		nunit.should be_a(Rake::Task)
		nunit.name.should eql('nunit')
	end
	it 'should make :nunit depend on @reports_dir' do
		nunit = Rake::Task[:nunit]
		nunit.prerequisites.should include('out/reports/nunit')
	end
	it 'should create a task to clobber the nunit-output' do
		cn = Rake::Task[:clobber_nunit]
		cn.should_not be_nil
	end
	it 'should create a rule matching the reports directory that will be hit by the suite to run'
end

describe NUnitTask, 'When initialised with suites dir' do
	it 'should use that dir' do
		sd = File.join(OUT_DIR, 'bong')
		nut = NUnitTask.new(:suites_dir=>sd)
		nut.suites_dir.should match(/#{re(sd)}/)
	end
end

describe NUnitTask, 'When initialised with out_dir' do
	it 'should use that dir' do
		d = File.join(OUT_DIR, 'junk')
		nut = NUnitTask.new(:out_dir => d)
		nut.out_dir.should match(/#{re(d)}/)
	end
end

describe NUnitTask, 'When initialised with runner options' do
	it 'should use those options' do
		o = {:exclude=>[]}
		nut = NUnitTask.new(:runner_options => {:exclude=>'unit,integration'})
		nut.runner_options.should_not be_empty
	end
end

describe NUnitTask, 'When initialised with dependencies' do
	before :all do
		task :foo
		@nut = NUnitTask.new(:dependencies=>[:foo])
	end
	it 'should create :nunit task' do
		nunit = Rake::Task[:nunit]
		nunit.should_not be_nil
		nunit.should be_a(Rake::Task)
		nunit.name.should eql('nunit')
	end
	it 'should read those dependencies' do
		@nut.dependencies.should include(:foo)
	end
	it 'should create :nunit task that depends on those' do
		nunit = Rake::Task[:nunit]
		nunit.prerequisites.should include('foo')
	end
end
