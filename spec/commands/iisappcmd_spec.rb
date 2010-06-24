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
      it_should_behave_like 'An IisAppCmd'
      it 'should default to http://*:80 when no bindings are supplied' do
        @cmd.cmd.should match(/\/bindings:http:\/\/\*:80/)
      end
      it 'should default to naming the site like the last directory name in physical-path' do
        @cmd.cmd.should match(/\/name:foo/)
      end
      it 'should generate an id'
    end
    describe 'When given an array of bindings' do
      before :all do
        @cmd = AddSiteIisAppCmd.new(:path => 'foo', :bindings => ['http://foo.com', 'http://bar.com'])
      end
      it 'should correctly join them into the command' do
        @cmd.cmd.should match(/\/bindings:http:\/\/foo\.com,http:\/\/bar\.com/)
      end
    end
    describe 'When given a csv-list of bindings' do
      before :all do
        @cmd = AddSiteIisAppCmd.new(:path => 'foo', :bindings => 'http://foo.com,http://bar.com')
      end
      it 'should correctly write them out into the command' do
        @cmd.cmd.should match(/\/bindings:http:\/\/foo\.com,http:\/\/bar\.com/)
      end
    end
    describe 'When given a name' do
      before :all do
        @cmd = AddSiteIisAppCmd.new(:path => 'foo', :name => 'bar')
      end
      it 'should use it to name the website' do
        @cmd.cmd.should match(/\/name:bar/)
      end      
    end
    describe 'When given an ID' do
      before :all do
        @cmd = AddSiteIisAppCmd.new(:path => 'foo', :id => 54)
      end
      it 'should use it' do
        @cmd.cmd.should match(/\/id:54/)
      end
		end
	end
end
