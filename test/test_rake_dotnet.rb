require 'test/unit'
require 'lib/rake_dotnet.rb'

class SvnTest < Test::Unit::TestCase
	def test_initialize_with_no_opts
		svn = Svn.new
		
		assert_equal "\"#{TOOLS_DIR}/svn/bin/svn.exe\"", svn.exe
	end
	
	def test_initialize_with_path
		svn = Svn.new :svn => 'foo/bar/svn.exe'
		
		assert_equal "\"foo/bar/svn.exe\"", svn.exe
	end
end