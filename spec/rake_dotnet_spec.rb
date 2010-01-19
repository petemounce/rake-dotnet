require 'lib/rake_dotnet'

Dir.glob("#{Pathname.new(__FILE__).dirname}/*/*.rb").each {|f| require f}
