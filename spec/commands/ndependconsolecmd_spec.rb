require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NDependConsoleCmd do
	describe 'When initialised with no options' do
		before(:all) do
			@cmd = NDependConsoleCmd.new
			@out_dir = File.expand_path(File.join(OUT_DIR, 'reports', 'ndepend')).gsub('/', '\\')
		end

		it 'should have sensible search paths' do
			@cmd.search_paths[0].should match(/#{TOOLS_DIR}\/ndepend/i)
		end
		it 'should use correct exe_name' do
			@cmd.exe.should match(/ndepend\.console\.exe/i)
		end
		it 'should look for a project file using a sensible name' do
			@cmd.project.should include(PRODUCT_NAME + '.ndepend.xml')
		end
		it 'should specify a sensible out_dir' do
			@cmd.out_dir.should include(@out_dir)
		end
		it 'should generate a sensible command to run' do
			@cmd.cmd.should match(/.*exe" ".*#{PRODUCT_NAME}\.ndepend\.xml"/i)
			@cmd.cmd.should include("/OutDir \"#{@out_dir}\"")
		end
		it 'should not publish' do
			@cmd.should_publish.should eql(false)
		end
	end

	describe 'When initialised with a project filename' do
		it 'should use that as the project file' do
			@cmd = NDependConsoleCmd.new({:project => 'Dipsy.ndepend'})
			@cmd.project.should include('Dipsy.ndepend')
		end
	end

	describe 'When initialised with an out_dir' do
		it 'should use it' do
			@cmd = NDependConsoleCmd.new(:out_dir => 'foo')
			@cmd.out_dir.should include('foo')
		end
	end

	describe 'When initialised so it publishes' do
		it 'should publish' do
			opt = {:should_publish => true}
			@cmd = NDependConsoleCmd.new(opt)
			@cmd.should_publish.should eql(true)
		end
		it 'should publish' do
			opt = {}
			opt[:should_publish] = true
			@cmd = NDependConsoleCmd.new(opt)
			@cmd.should_publish.should eql(true)
		end
	end
end
