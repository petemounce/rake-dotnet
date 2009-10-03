class SqlCmd < Cli
	attr_accessor :input_file, :query, :database
	
	def initialize(params={})
		sps = params[:search_paths] || []
		sps.push(File.join(TOOLS_DIR, 'sql'))
		sps.push(File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '100', 'tools', 'binn'))
		params = {:exe_name=>'sqlcmd.exe', :search_paths=>sps}.merge(params)
		super(params)
		
		@trusted = params[:trusted] || true
		unless @trusted 
			@user = params[:user] || DB_USER
			@password = params[:password] || DB_PASSWORD
		end
		@server = params[:server] || DB_SERVER

		#optionals and runtime settable
		@input_file = params[:input_file]
		@query = params[:query]
	end
	
	def credentials
		if @trusted
			return '-E'
		else
			return "-U \"#{@user}\" -P \"#{@password}\""
		end
	end
	
	def server
		return "-S \"#{@server}\""
	end
	
	def database
		return "-d \"#{@database}\"" unless @database.nil?
	end
	
	def input_file
		unless @input_file.nil?
			path = File.expand_path(@input_file).gsub('/', '\\')
			return "-i \"#{path}\""
		end
		return ''
	end
	
	def query
		return "-Q#{@query}" unless @query.nil?
	end
	
	def cmd
		return "#{exe} #{server} #{credentials} #{database} #{input_file} #{query}"
	end
	
	def run
		puts cmd if VERBOSE == true
		sh cmd
		revert_optionals
	end
	
	def revert_optionals
		@input_file = nil
		@query = nil
	end
end
