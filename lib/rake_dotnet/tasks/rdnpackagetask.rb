class RDNPackageTask < Rake::TaskLib
	include DependentTask
	attr_accessor :name, :items, :out_dir, :configuration, :exclude

	def initialize(params={})
		@name = params[:name]
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'pkg')
		@configuration = params[:configuration] || CONFIGURATION
		@exclude = params[:exclude] || ['**/.svn', '**/_svn', '**/.git', '**/obj']
		@items = params[:items] || []

		yield self if block_given?
		raise(ArgumentError, 'Must have a :name', caller) if @name.nil?
		raise(ArgumentError, 'Must have at least one item', caller) if @items.length < 1
		@main_task_name = "package_#{@name}".to_sym
		super(params)
		define
	end

	def remove_exclusions(exclusions, root, start_at)
		to_remove = []
		unless exclusions.nil?
			exclusions.each do |ex|
				glob = "#{root}/#{start_at}/#{ex}"
				to_remove << glob
			end
		end

		to_remove.each do |remove|
			Dir.glob(remove).each do |rm|
				rm_rf rm
			end
		end
	end

	def define
		directory @out_dir
		pkg = File.join(@out_dir, @name)
		pkg_regex = regexify(pkg)

		rule(/#{pkg_regex}-#{@configuration}-v\d+\.\d+\.\d+\.\d+\.zip/) do |r|
			rm_rf pkg if File.exist? pkg
			mkdir_p pkg
			cp 'version.txt', pkg
			@items.each do |item|
				f = Pathname.new(item[:from])
				to = Pathname.new(pkg)
				to = Pathname.new(File.join(pkg,item[:named])) unless item[:named].nil?
				mkdir_p to if File.exist? to
				cp_r f, to if f.directory?
				cp f, to unless f.directory?
				base = item[:named].nil? ? f.basename : item[:named]
				remove_exclusions(item[:exclude], to, base)
			end
			remove_exclusions(@exclude, pkg, '.')
			version = Versioner.new.get
			versioned_dir = File.join(@out_dir, "#{@name}-#{@configuration}-v#{version}")
			mv pkg, versioned_dir
			versioned_zip = versioned_dir + '.zip'
			sz = SevenZipCmd.new(versioned_zip)
			chdir versioned_dir do
				sz.run_add
			end
			rm_rf versioned_dir
		end

		desc "Generate zip'd package for #{@name}"
		task @main_task_name => [@out_dir] do
			version = Versioner.new.get
			Rake::Task["#{@out_dir}/#{@name}-#{@configuration}-v#{version}.zip"].invoke
		end

		desc "Generate zip'd packages for all package-tasks"
		task :package => @main_task_name

		desc "Delete all packages"
		task :clobber_package do
			rm_rf @out_dir
		end

		task :clobber => :clobber_package

		desc "Delete all packages and recreate them"
		task :repackage => [:clobber_package, :package]
	end
end
