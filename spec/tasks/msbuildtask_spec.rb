require 'spec'
require 'lib/rake_dotnet.rb'

describe MsBuildTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end

end
