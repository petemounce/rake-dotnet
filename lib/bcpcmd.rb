class BcpCmd < Cli
	attr_accessor :keep_identity_values, :keep_null_values, :wide_character_type, :field_terminator, :native_type
	attr_accessor :direction, :database, :table, :schema, :file

	def initialize(params={})
		sps = params[:search_paths] || []
		sps.push(File.join(TOOLS_DIR, 'sql'))
		sps.push(File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '100', 'tools', 'binn'))
		params = {:exe_name=>'bcp.exe', :search_paths=>sps}.merge(params)
		super(params)

		@trusted = params[:trusted] || true
		unless @trusted
			@user = params[:user] || DB_USER
			@password = params[:password] || DB_PASSWORD
		end

		@server = params[:server] || DB_SERVER

		@schema = params[:schema] || 'dbo'
	end

	def credentials
		if @trusted
			return '-T'
		else
			return "-U#{@user} -P#{@password}"
		end
	end

	def server
		return "-S#{@server}"
	end

	def direction
		return @direction.to_s
	end

	def db_object
		return "#{@database}.#{@schema}.#{@table}"
	end

	def path
		return '"' + File.expand_path(@file).gsub('/', '\\') + '"'
	end

	def keep_identity_values
		return '-E' unless @keep_identity_values.nil?
	end

	def keep_null_values
		return '-k' unless @keep_null_values.nil?
	end

	def wide_character_type
		return '-w' unless @wide_character_type.nil?
	end

	def field_terminator
		return "-t '#{@field_terminator}'" unless @field_terminator.nil?
	end

	def native_type
		return '-n' unless @native_type.nil?
	end

	def cmd
		return "#{exe} #{db_object} #{direction} #{path} #{server} #{credentials} #{keep_identity_values} #{keep_null_values} #{wide_character_type} #{field_terminator} #{native_type}"
	end

	def revert_optionals
		@keep_identity_values = nil
		@keep_null_values = nil
		@wide_character_type = nil
		@field_terminator = nil
		@native_type = nil
		@direction = nil
	end

	def run
		puts cmd if VERBOSE == true
		sh cmd
		revert_optionals
	end
end