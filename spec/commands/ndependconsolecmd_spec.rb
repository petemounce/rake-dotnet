require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe NDependConsoleCmd do
	describe 'When initialised with no options' do
		before(:all) do
			@nd = NDependConsoleCmd.new
			@out_dir = File.expand_path(File.join(OUT_DIR, 'reports', 'ndepend')).gsub('/', '\\')
		end

		it 'should have sensible search paths' do
			@nd.search_paths[0].should match(/#{TOOLS_DIR}\/ndepend/i)
		end
		it 'should use correct exe_name' do
			@nd.exe.should match(/ndepend\.console\.exe/i)
		end
		it 'should look for a project file using a sensible name' do
			@nd.project.should include(PRODUCT_NAME + '.ndepend.xml')
		end
		it 'should specify a sensible out_dir' do
			@nd.out_dir.should include(@out_dir)
		end
		it 'should generate a sensible command to run' do
			@nd.cmd.should match(/.*exe" ".*#{PRODUCT_NAME}\.ndepend\.xml"/i)
			@nd.cmd.should include("/OutDir \"#{@out_dir}\"")
		end
		it 'should not publish' do
			@nd.should_publish.should eql(false)
		end
	end

	describe 'When initialised with a project filename' do
		it 'should use that as the project file' do
			nd = NDependConsoleCmd.new(:project => 'Dipsy.ndepend')
			nd.project.should include('Dipsy.ndepend')
		end
	end

	describe 'When initialised with an out_dir' do
		it 'should use it' do
			nd = NDependConsoleCmd.new(:out_dir => 'foo')
			nd.out_dir.should include('foo')
		end
	end

	describe 'When initialised so it publishes' do
		it 'should publish' do
			nd = NDependConsoleCmd.new(:should_publish=>true)
			nd.should_publish.should eql(true)
		end
	end
end
