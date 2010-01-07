require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'cli.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', 'ndependconsolecmd.rb')
require 'constants_spec.rb'

describe NDependConsoleCmd, 'When initialised with no options' do
	before(:all) do
		@nd = NDependConsoleCmd.new
	end
	
	it 'should have sensible search paths' do
		@nd.search_paths[0].should match(/#{TOOLS_DIR}\/ndepend/)
	end
	it 'should use correct exe_name' do
		@nd.exe.should match(/ndepend\.console\.exe/)
	end
	it 'should look for a project file using a sensible name' do
		@nd.project.should include(PRODUCT_NAME + '.ndepend.xml')
	end
	it 'should specify a sensible out_dir' do
		@nd.out_dir.should include(OUT_DIR + '\\reports\\ndepend')
	end
	it 'should generate a sensible command to run' do
		@nd.cmd.should match(/.*exe" ".*#{PRODUCT_NAME}\.ndepend\.xml"/)
		@nd.cmd.should match(/\.ndepend\.xml" \/OutDir ".*#{OUT_DIR}\\reports\\ndepend"/)
	end
end

describe NDependConsoleCmd, 'When initialised with a project filename' do
	it 'should use that as the project file' do
		nd = NDependConsoleCmd.new(:project => 'Dipsy.ndepend')
		nd.project.should include('Dipsy.ndepend')
	end
end

describe NDependConsoleCmd, 'When initialised with an out_dir' do
	it 'should use it' do
		nd = NDependConsoleCmd.new(:out_dir => 'foo')
		nd.out_dir.should include('foo')
	end
end
