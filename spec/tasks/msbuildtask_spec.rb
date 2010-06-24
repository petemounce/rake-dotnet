require 'spec'
require 'lib/rake_dotnet.rb'
require 'constants_spec.rb'

describe MsBuildTask do
  after :all do
    Rake::Task.clear
    Rake::FileTask.clear
  end
  describe 'When initialised with default settings' do
    it_should_behave_like 'A DependentTask'
    before :all do
      @task = MsBuildTask.new
    end
  end
end
