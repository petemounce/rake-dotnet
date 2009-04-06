class Versioner
  def initialize(template_file=nil)
    tf = template_file || 'version.template.txt'
    file = Pathname.new(tf)
    @maj_min = file.read.chomp
  end

  def get
    "#{@maj_min}.#{build}.#{revision}"
  end

  def build
    ENV['BUILD_NUMBER'] || 0
  end

  def revision
    if (Pathname.new('.svn').exist?)
      SvnInfo.new(:path => '.').revision
    else
      '0' # YYYYMMDD is actually invalid for a {revision} number.
    end
  end
end


