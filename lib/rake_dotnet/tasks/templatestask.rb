class TemplatesTask < Rake::TaskLib
  include DependentTask

  def initialize(params={})
    @cfg = Config.new
    yield self if block_given?
    define
  end

  def define
    CLEAN.include("#{SRC_DIR}/**/*.erb")

    erbs = FileList.new("#{SRC_DIR}/**/*.erb")
    erbs.each do |erb_file|
      output = erb_file.sub('.erb','')
      file output do
        template = File.read(erb_file)
        erb = ERB.new(template)
        @cfg.current_template = Pathname.new(erb_file)
        result = erb.result(@cfg.get_binding)
        File.open(output,'w') { |f| f.puts result }
      end
      task :erbs => output
    end

    desc 'Generate output based on *.erb files from current ENVIRONMENT= configuration'
    task :erbs

    task :templates => :erbs
  end
end

class Config
	attr_accessor :root, :current_template
	def initialize(params={})
		@env = params[:env] || ENVIRONMENT
		@root = params[:root] || PRODUCT_ROOT
        file = Pathname.new("config.#{@env}.yml")
		yml = YAML::load( file.open )
		yml.each do |key, value|
			setter = "#{key}="
			self.class.send(:attr_accessor, key) if !respond_to? setter
			send setter, value
		end
	end

	def get_binding
		binding
	end
end
# YAML:
#settings_path: settings.xml
