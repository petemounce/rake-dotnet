module Rake
	class RDNPackageTask < TaskLib
		attr_accessor :targets
	
		def initialize(name, params={})
			@name = name
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
			pkg_root = File.join(pkg, @name)
			
			directory pkg # out/pkg
			directory pkg_root # out/pkg/bin
			
			package_file = pkg_root + '.zip'
			package_file_regex = regexify(package_file)
			
			@deps.each do |d|
				file package_file => d
				task :package => d
			end
			
			pkg_root_regex = regexify(pkg_root)
			rule(/#{pkg_root_regex}\.zip/) do |r|
				run_package
			end
			
			rule(/#{pkg_root_regex}-#{@configuration}\.zip/) do |r|
				run_package
			end
			rule(/#{pkg_root_regex}-#{@configuration}-v\d+\.\d+\.\d+\.\d+\.zip/) do |r|
				run_package
			end
			
			def run_package(configuration, version)
				@targets.each do |t|
					f = Pathname.new(t)
					if f.directory?
						cp_r f, pkg_root
					else
						cp f, pkg_root
					end
				end
				snipped = pkg_root.sub(pkg + '/', '')
				sz = SevenZip.new(package_file)
				chdir pkg_root do
					sz.run_add
				end
			end
			
			directory @out_dir
			
			desc "Generate zip'd packages for all package-tasks"
			task :package => [@out_dir, pkg, pkg_root, package_file]
			
			desc "Generate zip'd package for #{@name}"
			task "package_#{@name}".to_sym => [@out_dir, pkg, pkg_root, package_file]
			
			desc "Delete all packages"
			task :clobber_package do
				rm_rf pkg
			end
			
			task :clobber => :clobber_package
			
			desc "Delete all packages and recreate them"
			task :repackage => [:clobber_package, :package]
			
			self
		end
	end
end