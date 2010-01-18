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
			generate_for(r, 'cs')
		end

		rule(/#{src_dir_regex}\/[\w\.\d]+\/App_Code\/AssemblyInfo.cs/) do |r|
			generate_for(r, 'cs')
		end

		rule(/#{src_dir_regex}\/[\w\.\d]+\/My Project\/AssemblyInfo.vb/) do |r|
			generate_for(r, 'vb')
		end

		rule(/#{src_dir_regex}\/[\w\.\d]+\/App_Code\/AssemblyInfo.vb/) do |r|
			generate_for(r, 'vb')
		end

		def generate_for(target, language)
			dir = Pathname.new(target.name).dirname
			mkdir_p dir
			neighbour = Pathname.new(target.name + '.template')
			common = Pathname.new(File.join(@src_dir, "AssemblyInfo.#{language}.template"))
			if (neighbour.exist?)
				generate(neighbour, target.name)
			elsif (common.exist?)
				generate(common, target.name)
			end
		end

		desc 'Generate the AssemblyInfo.cs file from the template closest'
		task :assembly_info do
			Pathname.new(@src_dir).entries.each do |e|
				asm_info = asm_info_to_generate(e)
				Rake::FileTask[asm_info].invoke unless asm_info.nil?
			end
		end

		desc 'Generate all output from templates'
		task :templates => :assembly_info
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

	def asm_info_to_generate pn_entry
		if (pn_entry == '.' || pn_entry == '..' || pn_entry == '.svn')
			return nil
		end
		if (pn_entry == 'AssemblyInfo.cs.template' || pn_entry == 'AssemblyInfo.vb.template')
			return nil
		end

		proj = FileList.new("#{@src_dir}/#{pn_entry}/*.*proj").first
		return nil if proj.nil?

		proj_ext = Pathname.new(proj).extname
		path =
						case proj_ext
							when '.csproj' then
								File.join(@src_dir, pn_entry, 'Properties', 'AssemblyInfo.cs')
							when '.vbproj' then
								File.join(@src_dir, pn_entry, 'My Project', 'AssemblyInfo.vb')
							else
								nil
						end
		return path
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
		@product_name ||= PRODUCT_NAME
	end

	def configuration
		@configuration ||= CONFIGURATION
	end

	def company_name
		@company_name ||= COMPANY_NAME
	end

	def version
		@version ||= Versioner.new.get
	end
end
