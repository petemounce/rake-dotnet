require 'spec'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

describe IisAppCmd do
	shared_examples_for 'An IisAppCmd' do
		it 'should have some sensible default paths to look for exe' do
			@cmd.search_paths[0].should eql(File.join(ENV['systemroot'], 'system32', 'inetsrv'))
		end
		it 'should have correct exe_name' do
			@cmd.exe.should include('appcmd.exe')
		end
	end
	describe AddSiteIisAppCmd do
		describe 'When not provided with a physical path' do
			it 'should throw' do
				lambda { AddSiteIisAppCmd.new }.should raise_error(ArgumentError)
			end
		end
		describe 'When initialised with default settings' do
			before :all do
				@cmd = AddSiteIisAppCmd.new(:path => 'foo')
			end
			it 'should default to http://*:80 when no bindings are supplied'
			it 'should handle a list of bindings'
			it 'should handle a single binding'
			it 'should default to naming the site like the last directory name in physical-path'
			it 'should use a supplied website name'
			it 'should use a supplied id'
			it 'should generate an id when not supplied'
		end
	end
end
