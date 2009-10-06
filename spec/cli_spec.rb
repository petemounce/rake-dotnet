#cli spec
require '../lib/cli.rb'

describe Cli do
	it "should push nil onto the array of search paths" do
		cli = Cli.new
		cli.search_paths.should == [nil]
	end
	it "should push nil onto the array of search paths as the last item" do
		cli = Cli.new({:search_paths=>['foo']})
		cli.search_paths.should == ['foo', nil]
	end
	it "should not search for exe if it's specified in the params" do
		cli = Cli.new({:exe=>'foo', :search_paths=>['bar']})
		cli.exe.should == '"foo"'
	end
	it "should search for exe if we have an exe_name but no exe, and return exe_name (because we want it to look within system-path)" do
		cli = Cli.new({:exe_name=>'foo'})
		cli.exe.should == '"foo"'
	end
	it "should wrap the exe in double quotes whatever happens" do
		cli = Cli.new({:exe => 'foo'})
		cli.exe.should == '"foo"'
	end
	it "should return fully qualified path to exe when search-path is tried and exe is found there successfully" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli']})
		here = File.expand_path(File.dirname(__FILE__))
		cli.exe.should match(/#{here}.*/)
		cli.exe.should include('support/cli/foo.exe')
	end
	it "should return fully qualified path to exe at first find when search-path is tried and exe is found" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli/bar', 'support/cli']})
		here = File.expand_path(File.dirname(__FILE__))
		cli.exe.should match(/#{here}.*/)
		cli.exe.should include('support/cli/bar/foo.exe')
	end
	it "should return fq path to exe at first find, skipping non-finds" do
		cli = Cli.new({:exe_name => 'foo.exe', :search_paths=>['support/cli/notexist', 'support/cli']})
		here = File.expand_path(File.dirname(__FILE__))
		cli.exe.should match(/#{here}.*/)
		cli.exe.should include('support/cli/foo.exe')
	end
end