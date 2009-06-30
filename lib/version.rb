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
	fl = FileList.new("#{@bin_out}*")
	if ENV['TEAMCITY_BUILDCONF_NAME']
		pb = get_from_previous_binaries('.*-v\d+\.\d+\.(\d+)\.\d+')
		return pb unless pb.nil?# use a previous binaries-build if one exists
		# otherwise use the current environment variable
		bn = ENV['BUILD_NUMBER']
	end
	return 0 if bn == nil || !bn.match(/\d+/)
	return bn
  end

  def revision
    if (Pathname.new('.svn').exist?)
		if ENV['TEAMCITY_BUILDCONF_NAME']
			pb = get_from_previous_binaries('.*-v\d+\.\d+\.\d+\.(\d+)')
			return pb unless pb.nil?
		end
		return SvnInfo.new(:path => '.').revision
    else
		return '0' # YYYYMMDD is actually invalid for a {revision} number.
    end
  end
  
  def get_from_previous_binaries(regex)
	fl = FileList.new("#{@bin_out}*")
	fl.each do |e|
		re = regexify(@bin_out)
		unless e.match(/#{re}/).nil?
			matches = e.match(/#{regex}/)
			return matches[1] unless matches.nil?
		end
	end
	return nil
  end
end


