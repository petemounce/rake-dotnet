module Rake
	class MsBuildTask < TaskLib
		attr_accessor :name, :src_dir, :out_dir, :verbosity
	
		def initialize(name=:compile, src_dir='src', out_dir='build/bin/Debug', verbosity='m')
			@name = name
			@src_dir = src_dir
			@out_dir = out_dir
			@verbosity = verbosity
			yield self if block_given?
			define
		end
		
		def define
			rule(/#{out_dir_regex}\/[\w\.]+\.dll/) do |r|
				pn = Pathname.new(r.name)
				name = pn.basename.to_s.sub('.dll', '')
				project = File.join(@src_dir, name, name + '.csproj')
				mb = MsBuild.new(project, {:Configuration => configuration}, ['Build'], verbosity)
				mb.run
				h = Harvester.new(out_dir)
				isWeb = project.match(/"#{src_dir_regex}"\/Web\..*\//)
				if (isWeb)
					h.add(project.pathmap("%d/bin/**/*"))
				else
					h.add(project.pathmap("%d/bin/#{CONFIGURATION}/**/*"))
				end
				h.harvest
			end

			directory out_dir
			
			desc "Compile the specified projects (give relative paths) (otherwise, all matching src/**/*.*proj) and harvest output to #{out_dir}"
			task :compile,[:projects] => [out_dir] do |t, args|
				project_list = FileList.new('src/**/*.*proj')
				args.with_defaults(:projects => project_list)
				args.projects.each do |p|
					pn = Pathname.new(p)
					dll = File.join(out_dir, pn.basename.sub(pn.extname, '.dll'))
					Rake::FileTask[dll].invoke
				end
			end

		end
		
		def out_dir_regex
			regexify(@out_dir)
		end
		
		def src_dir_regex
			regexify(@src_dir)
		end
		
		def regexify(path)
			path.gsub('/', '\/').gsub('.', '\.')
		end
		
		def configuration
			od = Pathname.new(out_dir)
			od.basename
		end
	end
end

class MsBuild
	attr_accessor :project, :properties, :targets, :verbosity
	
	def initialize(project='default.proj', properties={}, targets=[], verbosity='n')
		@project = project
		@properties = properties
		@targets = targets
		@verbosity = verbosity
		@exe = '"' + File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe') + '"'
	end
	
	def run
		cmd = "#{@exe} #{project} /maxcpucount /v:#{@verbosity} /property:BuildInParallel=true /p:#{properties} /t:#{targets}"
		sh cmd
	end
	
	def project
		"\"#{@project}\""
	end
	
	def targets
		@targets.join(';')
	end
	
	def properties
		p = []
		@properties.each {|key, value| p.push("#{key}=#{value}") }
		p.join(';')
	end
end
