class Crap4nTask < Rake::TaskLib
	attr_accessor :out_dir

	def initialize(params={})
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'crap4n')

		yield self if block_given?
		define
	end

	def define
		directory @out_dir
		task :crap4n => @out_dir
		task :analyse => :crap4n
	end
end