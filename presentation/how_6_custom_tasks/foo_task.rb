require 'rake'
require 'rake/tasklib'

class FooTask < Rake::TaskLib
	def initialize
		define
	end

	# Create the tasks defined by this task lib.
	def define
		task :foo do
			puts 'foo!'
		end
	end
end
