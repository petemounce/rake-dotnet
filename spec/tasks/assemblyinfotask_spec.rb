require 'spec'
require 'rake'
require 'rake/tasklib'
require 'lib/rake_dotnet.rb'

describe AssemblyInfoTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end

	describe 'When initialised with default settings' do
		before :all do
			@at = AssemblyInfoTask.new
			@templates = Rake::Task[:templates]
		end
		it 'should define a rule to hit AssemblyInfo.cs files in projects\' Properties dir'
		it 'should define a rule to hit AssemblyInfo.cs files in websites\' App_Code dir'
		it 'should define a rule to hit AssemblyInfo.vb files in projects\' Properties dir'
		it 'should define a rule to hit AssemblyInfo.vb files in websites\' App_Code dir'
		it 'should define a task :assembly_info' do
			Rake::Task[:assembly_info].should_not be_nil
		end
		it 'should define a task :templates' do
			@templates.should_not be_nil
		end
		it 'should make :templates depend on :assembly_info' do
			@templates.should have(1).prerequisites
			@templates.prerequisites[0].should include('assembly_info')
		end
	end
end
