class RDNPackageTask < Rake::TaskLib
	attr_accessor :targets

	def initialize(name, params={})
		@name = name
		@out_dir = params[:out_dir] || OUT_DIR
		@deps = params[:deps] || []
		@configuration = params[:configuration] || CONFIGURATION
		globs = params[:globs] || []
		@targets = FileList.new globs
		@add_to_main_task = params[:add_to_main_task] || true

		yield self if block_given?
		define
	end

	def define
		out_pkg = File.join(@out_dir, 'pkg')
		out_pkg_name = File.join(out_pkg, @name)

		directory out_pkg
		directory out_pkg_name

		@deps.each do |d|
			task :package => d if @add_to_main_task
		end

		out_pkg_name_regex = RakeDotNet::regexify(out_pkg_name)

		rule(/#{out_pkg_name_regex}-#{@configuration}-v\d+\.\d+\.\d+\.\d+\.zip/) do |r|
			file_name = r.name.match(/(#{out_pkg_name_regex}).*/)[1].sub(out_pkg, '').sub('/','')
			version = r.name.match(/.*v(\d+\.\d+\.\d+\.\d+)\.zip/)[1]
			run_package(out_pkg, file_name, version)
		end

		directory @out_dir

		if @add_to_main_task
			desc "Generate zip'd packages for all package-tasks"
			task :package => [@out_dir, out_pkg, out_pkg_name] do
				version = Versioner.new.get
				Rake::Task["#{out_pkg_name}-#{@configuration}-v#{version}.zip"].invoke
			end
		end

		desc "Generate zip'd package for #{@name}"
		task "package_#{@name}".to_sym => [@out_dir, out_pkg, out_pkg_name] do
			version = Versioner.new.get
			Rake::Task["#{out_pkg_name}-#{@configuration}-v#{version}.zip"].invoke
		end

		desc "Delete all packages"
		task :clobber_package do
			rm_rf out_pkg
		end

		task :clobber => :clobber_package

		desc "Delete all packages and recreate them"
		task :repackage => [:clobber_package, :package]

		self
	end

	def run_package(root_dir, package_name, version)
		assembly_dir = File.join(root_dir, package_name)
		mkdir_p assembly_dir
		@targets.each do |t|
			f = Pathname.new(t)
			if f.directory?
				cp_r f, File.join(assembly_dir, "#{f.basename}-#{@configuration}-v#{version}")
			else
				cp f, assembly_dir
			end
		end
		versioned_assembly_dir = File.join(root_dir, "#{package_name}-#{@configuration}-v#{version}")
		mv assembly_dir, versioned_assembly_dir
		vzip = versioned_assembly_dir + '.zip'
		sz = SevenZipCmd.new(vzip)
		chdir versioned_assembly_dir do
			sz.run_add
		end
	end
end
