class MsBuildCmd < Cli
  def initialize(params={})
    sps = params[:search_paths] || []
    sps << File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v4.0')
    sps << File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v3.5')
    sps << File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v2.0.50727')
    super(params.merge(:exe_name => 'msbuild.exe', :search_paths => sps))

    @project = params[:project]
    raise(ArgumentError, 'Must supply :project', caller) if @project.nil?
    @properties = params[:properties] || {}
    @targets = params[:targets] || []
    @verbosity = params[:verbosity] || 'n'
    @working_dir = params[:working_dir] || '.'
	end

	def cmd
    "#{super} #{project} /maxcpucount #{verbosity} #{properties} #{targets}"
	end

	def run
		if @working_dir
			chdir(@working_dir) do
				puts cmd if verbose
				sh cmd
			end
		end
	end

	def project
    "\"#{File.expand_path(@project).gsub('/','\\')}\""
  end

  def verbosity
    "/v:#{@verbosity}"
	end

	def targets
    return '' if @targets.length == 0
    '/t:' + @targets.join(';')
	end

	def properties
    return '' if @properties.length == 0
		p = []
		@properties.each { |key, value| p.push("#{key}=#{value}") }
    '/p:' + p.join(';')
	end
end
