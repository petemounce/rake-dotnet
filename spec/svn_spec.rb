require File.join(File.dirname(__FILE__), '..','lib','svn.rb')

TOOLS_DIR = 'support/'
describe Svn do
	before :all do
		Dir.chdir('spec')
	end
	after :all do
		Dir.chdir('..')
	end
	it "should know 3 sensible default search paths" do
		svn = Svn.new
		svn.search_paths[0].should include(TOOLS_DIR)
		svn.search_paths[1].should include(ENV['PROGRAMFILES'])
		svn.search_paths[2].should include(ENV['PROGRAMFILES'])
		svn.search_paths[3].should == nil
	end
end

describe SvnExport do
	before :all do
		Dir.chdir('spec')
	end
	after :all do
		Dir.chdir('..')
	end
	it "should require src" do
		lambda { SvnExport.new({:dest=>'support/svn/dest'})}.should raise_error(ArgumentError)
	end
	it "should require dest" do
		lambda { SvnExport.new({:src=>'support/svn/src'}) }.should raise_error(ArgumentError)
	end
	it "export should generate correct command line when run" do
		svn = SvnExport.new({:src=>'support/svn/src',:dest=>'support/svn/dest'})
		puts svn.exe
		puts 'cmd: ' + svn.cmd
		svn.cmd.should match(/".*svn\.exe.*/)
		svn.cmd.should match(/".* export.*/)
		svn.cmd.should match(/".* ".*support\/svn\/src".*/)
		svn.cmd.should match(/".* ".*support\/svn\/dest"/)
	end
end

describe SvnInfo do
	before :all do
		Dir.chdir('spec')
	end
	after :all do
		Dir.chdir('..')
	end
end