require 'rake'
require 'rake/tasklib'

class BazTask < Rake::TaskLib
	attr_accessor :message

	def initialize
		@message = 'the droids that will be your downfall if only you didn''t have a weak mind'
		yield self if block_given?
		define
	end

	# Create the tasks defined by this task lib.
	def define
		task :baz do
			puts 'these are ' + @message
		end
	end
end
