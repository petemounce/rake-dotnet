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

		raise(ArgumentError, 'Must have a physical path', caller) if @path.nil?
	end

	def bindings
		if @bindings.nil?
			return 'http://*:80'
    elsif @bindings.is_a? Array
			return @bindings.join(',')
		else
			return @bindings
		end
	end

	def name
		return @name unless @name.nil?
    result = Pathname.new(@path).basename
    return result
	end

	def id
		return "/id:#{@id}" unless @id.nil?
		return ''
	end

	def cmd
		return "#{exe} add site /name:#{name} #{id} /bindings:#{bindings} /physicalPath:#{@path}"
	end

	def run
		puts cmd if verbose
		sh cmd
	end
end
