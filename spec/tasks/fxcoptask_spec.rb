require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'
require 'spec/tasks/dependenttask_spec.rb'

describe FxCopTask do
  after :all do
    Rake::Task.clear
    Rake::FileTask.clear
  end
  describe 'When initialised with default settings' do
    before :all do
      @task = FxCopTask.new
      @out_dir = File.join(OUT_DIR, 'reports')
      @fxcop = Rake::Task[:fxcop]
      @report = Rake::FileTask["#{@out_dir}/#{PRODUCT_NAME}.fxcop.xml"]
    end
    it_should_behave_like 'A DependentTask'
    it 'should use a sensible product_name' do
      @task.product_name.should eql(PRODUCT_NAME)
    end
    it 'should use a sensible out-dir to write reports to' do
      @task.report_dir.should eql(@out_dir)
    end
    it 'should define a directory task for the out-dir' do
      @out_dir.should_not be_nil
    end
    it 'should define a task, :fxcop' do
      @fxcop.should_not be_nil
    end
    it 'should create a file-task for the report file' do
      @report.should_not be_nil
    end
    it 'should not make :fxcop depend on the report file because otherwise the arguments are not processed' do
      @fxcop.prerequisites.should_not include(@report.name)
    end
    it 'should make out-dir task dependent on the report file' do
      @report.prerequisites.should include(@out_dir)
    end
    it 'should use a sensible file for the report' do
      @task.name.should eql(File.join(@out_dir, "#{PRODUCT_NAME}.fxcop.xml"))
    end
    it 'should look in a sensible place for libraries to process' do
      @task.suites_dir.should eql(Bin_out)
    end
    it 'should not define any extra dependencies for :fxcop' do
      @fxcop.should have(0).prerequisites
    end
    it 'should define a :clobber_fxcop task' do
      Rake::Task[:clobber_fxcop].should_not be_nil
    end
  end

  describe 'When given dependencies' do
    before :all do
      @task = FxCopTask.new(:dependencies=>[:foo])
    end
    it_should_behave_like 'A DependentTask'
    it 'should use them' do
      Rake::Task[:fxcop].prerequisites.should include('foo')
    end
  end

  describe 'When we want to apply the out xsl' do
    before :all do
      @task = FxCopTask.new(:fxcop_options=>{:apply_out_xsl=>true})
    end
    it_should_behave_like 'A DependentTask'
    it 'should output to an html file' do
      @task.name.should include('html')
    end
  end
end
