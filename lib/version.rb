class Versioner
  def initialize(template_file=nil, opts={})
    tf = template_file || 'version.template.txt'
    file = Pathname.new(tf)
    @maj_min = file.read.chomp
	@bin_out = opts[:bin_out] || File.join(OUT_DIR, 'bin')
  end

  def get
    "#{@maj_min}.#{build}.#{revision}"
  end

  def build
	fl = FileList.new("#{bin_out}*")
	bn = 0
	if ENV['TEAMCITY_BUILDCONF_NAME']
		# use a previous binaries-build if one exists
		fl.each do |e|
			if (e.test(regexify(@bin_out)))
				bn = e.match(/\w+-v\d+\.\d+\.(\d+)\.\d+\//)[1]
				return bn
			end
		end
		# otherwise use the current environment variable
		bn = ENV['BUILD_NUMBER']
	end
	return 0 if bn == nil || !bn.match(/\d+/)
	return bn
  end

  def revision
    if (Pathname.new('.svn').exist?)
      SvnInfo.new(:path => '.').revision
    else
      '0' # YYYYMMDD is actually invalid for a {revision} number.
    end
  end
end


