require 'spec'
require 'lib/rake_dotnet.rb'

describe FxCopTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with default settings' do
		before :all do
			@ft = FxCopTask.new
			@out_dir = File.join(OUT_DIR, 'reports') 
			@fxcop = Rake::Task[:fxcop]
			@report = Rake::FileTask["#{@out_dir}/#{PRODUCT_NAME}.fxcop.xml"]
		end
		it 'should use a sensible product_name' do
			@ft.product_name.should eql(PRODUCT_NAME)
		end
		it 'should use a sensible out-dir to write reports to' do
			@ft.report_dir.should eql(@out_dir)
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
			@ft.name.should eql(File.join(@out_dir, "#{PRODUCT_NAME}.fxcop.xml"))
		end
		it 'should look in a sensible place for libraries to process' do
			@ft.suites_dir.should eql(Bin_out)
		end
		it 'should not define any extra dependencies for :fxcop' do
			@fxcop.should have(0).prerequisites
		end
		it 'should define a :clobber_fxcop task' do
			Rake::Task[:clobber_fxcop].should_not be_nil
		end
	end

	describe 'When given dependencies' do
		it 'should use them' do
			FxCopTask.new(:deps=>[:foo])
			Rake::Task[:fxcop].prerequisites.should include('foo')
		end
	end

	describe 'When we want to apply the out xsl' do
		it 'should output to an html file' do
			ft = FxCopTask.new(:fxcop_options=>{:apply_out_xsl=>true})
			ft.name.should include('html')
		end
	end
end
