require 'spec'
require 'lib/rake_dotnet.rb'

describe RDNPackageTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end

end
