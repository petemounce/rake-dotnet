class Crap4nTask < Rake::TaskLib
	attr_accessor :out_dir, :coverage_dir, :metrics_dir

	def initialize(params={})
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'crap4n')
		@coverage_dir = params[:coverage_dir] || File.join(OUT_DIR, 'reports', 'ncover')
		@metrics_dir = params[:metrics_dir] || File.join(OUT_DIR, 'reports', 'ncover')

		yield self if block_given?
		define
	end

	def define
		directory @out_dir
		task :crap4n => @out_dir
		task :analyse => :crap4n

		out_dir_regex = regexify(@out_dir)
		rule(/#{out_dir_regex}\/.*\.crap4n\.xml/) do |r|
# TODO: Work in progress
		end

		task :crap4n do
			coverage_files = FileList.new("#{@coverage_dir}/*.coverage.xml")
			metrics_files = FileList.new("#{@metrics_dir}/*.coverage.xml")
			coverage_files.each do |cov|
				name = Pathname.new(cov).basename.sub('.coverage.xml', '')
				Rake::Task["#{@out_dir}/#{name}.crap4n.xml"]
			end
		end
	end
end
