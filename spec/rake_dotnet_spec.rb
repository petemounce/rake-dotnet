require 'lib/rake_dotnet'
require 'constants_spec'
require 'versioner_spec'

Dir.glob("#{Pathname.new(__FILE__).dirname}/*/*.rb").each {|f| require f}
