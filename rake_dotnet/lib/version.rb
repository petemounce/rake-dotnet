class Versioner
	def initialize(template_file=nil)
		tf = template_file || 'version.template.txt'
		template_file = Pathname.new(tf)
		@maj_min = template_file.read.chomp
		@build = ENV['BUILD_NUMBER'] || 0
		@svn_info = SvnInfo.new(:path => '.')
	end
	
	def get
		"#{@maj_min}.#{@build}.#{@svn_info.revision}"
	end
end


