class IisAppCmd < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(ENV['systemroot'], 'system32', 'inetsrv')
		super(params.merge({:exe_name=>'appcmd.exe', :search_paths=>sps}))
	end
end
class AddSiteIisAppCmd < IisAppCmd
	def initialize(params={})
		super
		@path = params[:path]
		@name = params[:name]
		@id = params[:id]
		@bindings = params[:bindings]
	end

	def bindings
		if @bindings.nil?
			return 'http://*:80'
		elsif is_a? Array
			return @bindings.join(',')
		else
			return @bindings
		end
	end

	def name
		return @name unless @name.nil?
		pn = Pathname.new(@path)
		exp = File.expand_path(pn.dirname)
		return exp.gsub('/','\\')
	end

	def id
		return @id unless @id.nil?
		#TODO: Generate an ID
	end

	def cmd
		return "#{exe} add site /name:#{name} /id:#{id} /bindings:#{bindings} /path:#{@path}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
	end
end