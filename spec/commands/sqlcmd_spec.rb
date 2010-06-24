require 'spec'
require 'lib/rake_dotnet.rb'

describe SqlCmd do
	it "should have sensible default search_paths when constructed" do
		sql = SqlCmd.new
		sql.search_paths[0].should match(/#{TOOLS_DIR}\/sql/)
		sql.search_paths[1].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/100/tools/binn")
		sql.search_paths[2].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/90/tools/binn")
		sql.search_paths[3].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/80/tools/binn")
		sql.search_paths[4].should be_nil
	end
	it "should assume trusted connection by default" do
		sql = SqlCmd.new
		sql.cmd.should match(/.*-E.*/)
	end
	it "should read credentials from constants if trusted=false" do
		sql = SqlCmd.new({:trusted => false})
		sql.cmd.should match(/.*-U "#{DB_USER}"/)
		sql.cmd.should match(/.*-P "#{DB_PASSWORD}"/)
	end
	it "should read server from constant if not specified" do
		sql = SqlCmd.new
		sql.cmd.should match(/.*-S ".".*/)
	end
	it "should use a database when told to" do
		sql = SqlCmd.new
		sql.database = 'db'
		sql.cmd.should match(/.*-d "db".*/)
	end
	it "should use an input file with an expanded path with forward slashes replaced with backslashes when told to" do
		sql = SqlCmd.new
		sql.input_file = 'support/sqlcmd/foo.sql'
		sql.cmd.should match(/.*-i "\w:\\.*\\support\\sqlcmd\\foo\.sql".*/)
	end
	it "should use a supplied query" do
		sql = SqlCmd.new
		sql.query = 'SELECT bar FROM dbo.foo'
		sql.cmd.should match(/.*-Q "SELECT bar FROM dbo\.foo".*/)
	end
	it "should revert optional attributes when told to" do
		sql = SqlCmd.new
		sql.query = 'SELECT foo FROM bar'
		sql.input_file = 'foo.sql'

		sql.revert_optionals

		sql.query.should be_nil
		sql.input_file.should == ''
	end
end
