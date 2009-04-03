module Rake
  class AssemblyInfoTask < Rake::TaskLib
    attr_accessor :product_name, :configuration, :company_name, :version

    def initialize(params={})
      @src_dir = params[:src_dir] || SRC_DIR
      yield self if block_given?
      define
    end

    def define
      src_dir_regex = regexify(@src_dir)
      rule(/#{src_dir_regex}\/[\w\.\d]+\/Properties\/AssemblyInfo.cs/) do |r|
        nextdoor = Pathname.new(r.name + '.template')
        common = Pathname.new(File.join(@src_dir, 'AssemblyInfo.cs.template'))
        if (nextdoor.exist?)
          generate(nextdoor, r.name)
        elsif (common.exist?)
          generate(common, r.name)
        end
      end

      desc 'Generate the AssemblyInfo.cs file from the template closest'
      task :assembly_info do |t|
        # for each project, invoke the rule
        Dir.foreach(@src_dir) do |e|
          asm_info = File.join(@src_dir, e, 'Properties', 'AssemblyInfo.cs')
          if is_project e
            Rake::FileTask[asm_info].invoke
          end
        end
      end

      self
    end

    def generate(template_file, destination)
      content = template_file.read
      token_replacements.each do |key, value|
        content = content.gsub(/(\$\{#{key}\})/, value.to_s)
      end
      of = Pathname.new(destination)
      of.delete if of.exist?
      of.open('w') { |f| f.puts content }
    end

    def is_project entry
      if (entry == '.' || entry == '..' || entry == '.svn')
        return false
      end
      if (entry == 'AssemblyInfo.cs.template')
        return false
      end
      #puts "#{entry} is directory? #{File.directory?(entry)}"
      #return File.directory?(entry)
      return true
    end

    def token_replacements
      r = {}
      r[:built_on] = Time.now
      r[:product] = product_name
      r[:configuration] = configuration
      r[:company] = company_name
      r[:version] = version
      return r
    end

    def product_name
      @product_name ||= 'NRWS rake_dotnet'
    end

    def configuration
      @configuration ||= 'Debug'
    end

    def company_name
      @company_name ||= 'NRWS'
    end

    def version
      @version ||= Versioner.new.get
    end
  end
end
