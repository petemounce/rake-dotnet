require 'spec'
require 'lib/rake_dotnet.rb'

describe Versioner do
	describe 'When initialised with defaults' do
    before :all do
      @v = Versioner.new
    end
    it 'should look in working directory for template file' do
      @v.template_file.should == Pathname.new(Versioner::VERSION_TEMPLATE_FILE)
    end
	end
	describe 'When initialised with a template file path' do
    it 'should use it' do
      Versioner.new('foo.txt').template_file.should == Pathname.new('foo.txt')
    end
	end
end
