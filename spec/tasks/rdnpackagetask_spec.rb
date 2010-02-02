require 'spec'
require 'lib/rake_dotnet.rb'

describe RDNPackageTask do
	after :all do
		Rake::Task.clear
		Rake::FileTask.clear
	end
	describe 'When initialised with no name' do
		it 'should throw ArgumentError' do
			lambda { RDNPackageTask.new }.should raise_error(ArgumentError)
		end
	end
	describe 'When initialised with no items' do
		it 'should throw because we need to package at least one item' do
			lambda { RDNPackageTask.new(:name=>'bin')}.should raise_error(ArgumentError)
		end
	end
	describe 'When initialised with minimum-required settings' do
		before :all do
			@pt = RDNPackageTask.new(
							:name=>'bin',
							:items=>[{:from=>'bin'}]
			)
			@package = Rake::Task[:package]
			@repackage = Rake::Task[:repackage]
			@out_dir = Rake::FileTask["#{OUT_DIR}/pkg"]
			@clobber = Rake::Task[:clobber]
			@clobber_package = Rake::Task[:clobber_package]
			@package_bin = Rake::Task['package_bin']
		end
		it 'should assume default configuration' do
			@pt.configuration.should eql(CONFIGURATION)
		end
		it 'should have 1 item defined' do
			@pt.should have(1).items
		end
		it 'should define sensible excludes' do
			@pt.exclude.should include('**/.svn')
			@pt.exclude.should include('**/_svn')
			@pt.exclude.should include('**/.git')
			@pt.exclude.should include('**/obj')
		end
		it 'should have a sensible output directory' do
			@pt.out_dir.should eql("#{OUT_DIR}/pkg")
		end
		it 'should create a directory task for the out_dir' do
			@out_dir.should_not be_nil
		end
		it 'should define a task to run the specific package' do
			@package_bin.should_not be_nil
		end
		it 'should make :package_bin depend on out_dir' do
			@package_bin.prerequisites.should include(@out_dir.name)
		end
		it 'should define :package' do
			@package.should_not be_nil
		end
		it 'should have no external dependencies' do
			@package.should have(1).prerequisites
			@package.prerequisites.should include(@package_bin.name)
		end
		it 'should define :clobber_package' do
			@clobber_package.should_not be_nil
		end
		it 'should make :clobber depend on :clobber_package' do
			@clobber.prerequisites.should include('clobber_package')
		end
		it 'should define :repackage' do
			@repackage.should_not be_nil
		end
		it 'should make :repackage depend on :clobber_package then :package' do
			@repackage.prerequisites[0].should eql('clobber_package')
			@repackage.prerequisites[1].should eql('package')
		end
		it 'should define a rule to build the package'
	end
	describe 'When given an out_dir' do
		it 'should use it' do
			RDNPackageTask.new(:name=>'bin',
							:items=>[{:from=>'bin'}], :out_dir=>'foo').out_dir.should eql('foo')
		end
	end
	describe 'When given a configuration' do
		it 'should use it' do
			RDNPackageTask.new(:name=>'bin',
							:items=>[{:from=>'bin'}], :configuration=>'Release').configuration.should eql('Release')
		end
	end
	describe 'When given an item' do
		it 'should add it to the array' do
			pt = RDNPackageTask.new(:name=>'bin', :items=>[{:src=>'site'}])
			pt.should have(1).items
			pt.items.should include({:src=>'site'})
		end
	end
end
