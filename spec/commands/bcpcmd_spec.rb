require 'spec'
require 'lib/rake_dotnet.rb'

describe BcpCmd do
	before :each do
		@params = {:database=>'foo', :table=>'bar', :direction=>:in, :file=>'data.bcp'}
	end
	it "should have sensible default search paths" do
		bcp = BcpCmd.new
		bcp.search_paths[0].should match(/#{TOOLS_DIR}\/sql/)
		bcp.search_paths[1].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/100/tools/binn")
		bcp.search_paths[2].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/90/tools/binn")
		bcp.search_paths[3].should include("#{ENV['PROGRAMFILES']}/Microsoft SQL Server/80/tools/binn")
		bcp.search_paths[4].should be_nil
	end
	it "should assume trusted connection by default" do
		bcp = BcpCmd.new(@params)
		bcp.cmd.should match(/.*-T.*/)
	end
	it "should read credentials from constants if trusted=false" do
		bcp = BcpCmd.new(@params.merge({:trusted => false}))
		bcp.cmd.should match(/.*-U "#{DB_USER}"/)
		bcp.cmd.should match(/.*-P "#{DB_PASSWORD}"/)
	end
	it "should read server from constant if not specified" do
		bcp = BcpCmd.new(@params)
		bcp.cmd.should match(/.*-S ".".*/)
	end
	it "should write out a basic command line with the minimum required parameters supplied by constructor" do
		bcp = BcpCmd.new(@params)
		bcp_assert bcp
	end
	it "should write out a basic command line with the minimum required parameters supplied by accessors" do
		bcp = BcpCmd.new
		bcp.database = @params[:database]
		bcp.table = @params[:table]
		bcp.direction = @params[:direction]
		bcp.file = @params[:file]
		bcp_assert bcp
	end
	it "should write out extra parameters when supplied by accessors" do
		bcp = BcpCmd.new(@params)
		bcp.keep_identity_values = true
		bcp.keep_null_values = true
		bcp.wide_character_type = true
		bcp.field_terminator = ','
		bcp.native_type = true

		bcp_assert bcp
		bcp.cmd.should match(/.* -E.*/)
		bcp.cmd.should match(/.* -k.*/)
		bcp.cmd.should match(/.* -w.*/)
		bcp.cmd.should match(/.* -t ','.*/)
		bcp.cmd.should match(/.* -n.*/)
	end
	it "should revert optional attributes when told to" do
		bcp = BcpCmd.new
		bcp.keep_identity_values = true
		bcp.keep_null_values = true
		bcp.wide_character_type = true
		bcp.field_terminator = ','
		bcp.native_type = true

		bcp.revert_optionals

		bcp.keep_identity_values.should be_nil
		bcp.keep_null_values.should be_nil
		bcp.wide_character_type.should be_nil
		bcp.field_terminator.should be_nil
		bcp.native_type.should be_nil
	end

	def bcp_assert(bcp)
		bcp.cmd.should match(/.*\[foo\]\.\[dbo\]\.\[bar\].*/)
		bcp.cmd.should match(/.* in .*/)
		bcp.cmd.should match(/.* "\w:\\.*data\.bcp".*/)
		bcp.cmd.should match(/.* -S \".\"/)
		bcp.cmd.should match(/.* -T.*/)
	end
end
