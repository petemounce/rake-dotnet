require 'rake'
require 'rake/tasklib'

class BarTask < Rake::TaskLib
	attr_accessor :message

	def initialize
		@message = 'ouch!'
		yield self if block_given?
		define
	end

	# Create the tasks defined by this task lib.
	def define
		task :bar do
			puts 'a man walked into a bar and said: ' + @message
		end
	end
end
