module Rake
	class RDNPackageTask < TaskLib
		attr_accessor :targets
	
		def initialize(name, version, params={})
			@name = name
			@version = version
			@out_dir = params[:out_dir] || OUT_DIR
			@deps = params[:deps] || []
			@configuration = params[:configuration] || CONFIGURATION
			globs = params[:globs] || []
			@targets = FileList.new globs
			
			yield self if block_given?
			define
		end
		
		def define
			pkg = File.join(@out_dir, 'pkg')
			pkg_root = renamed(File.join(pkg, @name))
			
			directory pkg
			directory pkg_root
			
			package_file = pkg_root + '.zip'
			package_file_regex = regexify(package_file)
			
			@deps.each do |d|
				file package_file => d
				task :package => d
			end
			
			rule(/#{package_file_regex}/) do |r|
				@targets.each do |t|
					f = Pathname.new(t)
					if f.directory?
						mv "#{t}/*", pkg_root
					else
						mv t, pkg_root
					end
				end
				snipped = pkg_root.sub(pkg + '/', '')
				chdir pkg do
					sz = SevenZip.new('../../'+package_file, snipped, {:sevenzip=>File.join('..','..',TOOLS_DIR, '7zip', '7z.exe')})
					sz.run_add
				end
			end
			
			directory @out_dir
			
			desc "Generate zip'd packages for all package-tasks"
			task :package => [@out_dir, pkg, pkg_root, package_file]
			
			desc "Delete all packages"
			task :clobber_package do
				rm_rf pkg
			end
			
			task :clobber => :clobber_package
			
			desc "Delete all packages and recreate them"
			task :repackage => [:clobber_package, :package]
			
			self
		end
		
		def renamed(target)
			"#{target}-#{@configuration}-v#{@version}"
		end
	end
end