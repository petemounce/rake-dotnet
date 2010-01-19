require 'spec'
require 'lib/rake_dotnet.rb'

describe FxCopTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end

end
