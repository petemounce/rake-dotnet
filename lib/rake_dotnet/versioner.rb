class Versioner
	def initialize(template_file=nil, opts={})
		tf_path = template_file || 'version.template.txt'
		@tf = Pathname.new(tf_path)
		@vf = Pathname.new(tf_path.sub('.template', ''))
	end

	def get
		return @vf.read.chomp if @vf.exist?

		v = "#{maj_min}.#{build}.#{revision}"
		@vf.open('w') {|f| f.write(v) }
		return v
	end

	def maj_min
		return @tf.read.chomp
	end

	def build
		bn = ENV['BUILD_NUMBER']
		return 0 if bn == nil || !bn.match(/\d+/)
		return bn
	end

	def revision
		if (Pathname.new('.svn').exist?)
			return SvnInfo.new(:path => PRODUCT_ROOT).revision
		else
			# TODO: return something numeric but sane for non-numeric revision numbers (eg DVCSs)
			return '0' # YYYYMMDD is actually invalid for a {revision} number.
		end
	end
end

Version_txt = 'version.txt'
file Version_txt do
	Versioner.new.get
end
task :version => Version_txt
task :assembly_info => Version_txt
