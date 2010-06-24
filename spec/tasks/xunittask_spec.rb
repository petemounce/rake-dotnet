require 'spec'
require 'lib/rake_dotnet.rb'

describe XUnitTask do
  after :all do
    Rake::Task.clear
    Rake::FileTask.clear
  end

  describe 'When initialised with default settings' do
    before :all do
      @task = XUnitTask.new
      @xunit = Rake::Task[:xunit]
      @out_dir = File.join(OUT_DIR, 'reports', 'tests')
    end
    it_should_behave_like 'A DependentTask'
    it 'should look in a sensible place for test-suite DLLs to run' do
      @task.suites_dir.should eql(Bin_out)
    end
    it 'should dump reports to a sensible place' do
      @task.reports_dir.should eql(@out_dir)
    end
    it 'should define a directory to dump reports into' do
      Rake::FileTask[@out_dir].should_not be_nil
    end
    it 'should define a task, :xunit' do
      @xunit.should_not be_nil
    end
    it 'should make :xunit depend on reports dir' do
      @xunit.prerequisites.should include(@out_dir)
    end
    it 'should not have extra dependencies' do
      @xunit.should have(1).prerequisites
    end
    it 'should define a rule that hits DLLs in the suites-directory'
    it 'should define a rule that hits DLLs in the suites-directory with a typing shortcut xt-{dll}'
    it 'should define a task to clobber output' do
      Rake::Task[:clobber_xunit].should_not be_nil
    end
    it 'should enlist :xunit in the :tests task\'s dependencies' do
      Rake::Task[:tests].prerequisites.should include('xunit')
    end
  end

  describe 'When given a suites-dir' do
    before :all do
      @task = XUnitTask.new(:suites_dir=>'foo') 
    end
    it_should_behave_like 'A DependentTask'
    it 'should use it' do
      @task.suites_dir.should eql('foo')
    end
  end

  describe 'When given an out-dir' do
    before :all do
      @task = XUnitTask.new(:reports_dir=>'foo')
    end
    it_should_behave_like 'A DependentTask'
    it 'should use it' do
      @task.reports_dir.should eql('foo')
    end
  end

  describe 'When given dependencies' do
    before :all do
      @task = XUnitTask.new(:dependencies=>[:dooby])
    end
    it_should_behave_like 'A DependentTask'
    it 'should use them' do
      @task.dependencies.should include(:dooby)
      Rake::Task[:xunit].prerequisites.should include('dooby')
    end
  end
end
