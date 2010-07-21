require 'spec'
require 'lib/rake_dotnet.rb'

describe SvnCmd do
	it "should know 3 sensible default search paths" do
		svn = SvnCmd.new
		svn.search_paths[0].should include(TOOLS_DIR)
		svn.search_paths[1].should include(ENV['PROGRAMFILES'])
		svn.search_paths[2].should include(ENV['PROGRAMFILES'])
		svn.search_paths[3].should == nil
	end
end

describe SvnExport do
	it "should require src" do
		lambda { SvnExport.new({:dest=>'support/svn/dest'}) }.should raise_error(ArgumentError)
	end
	it "should require dest" do
		lambda { SvnExport.new({:src=>'support/svn/src'}) }.should raise_error(ArgumentError)
	end
	it "export should generate correct command line when run" do
		svn = SvnExport.new({:src=>'support/svn/src', :dest=>'support/svn/dest'})
		cmd = svn.cmd
		cmd.should_not be_nil
		cmd.should match(/".*svn\.exe.*/)
		cmd.should match(/".* export.*/)
		cmd.should match(/".* ".*support\/svn\/src".*/)
		cmd.should match(/".* ".*support\/svn\/dest"/)
	end
end

describe SvnInfo do
	it "should default to using current directory when path not specified" do
		si = SvnInfo.new
		si.cmd.should match(/".*svn\.exe.*/)
		si.cmd.should match(/".* info.*"/)
		si.cmd.should match(/.* info "."/)
	end
	it "should specify path when supplied as argument" do
		si = SvnInfo.new({:path=>'support/svn'})
		si.cmd.should match(/".*svn\.exe.*/)
		si.cmd.should match(/".* info.*"/)
		si.cmd.should match(/.* info "support\/svn"/)
	end
end
