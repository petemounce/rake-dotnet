#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

module Rake
	class AssemblyInfoFileTask < Rake::TaskLib
		# Name of the main, top level task.  (default is :asminfo)
		attr_accessor :name, :template_file, :product_name, :configuration, :company_name, :version

		# Create an AssemblyInfo file-task; define a task to run it whose name is :assembly_info
		def initialize(name) # :yield: self
			@name = name
			yield self if block_given?
			define
		end

		# Create the tasks defined by this task lib.
		def define
			require 'pathname'
			
			puts 'define ai: ' + @name + ' ' + @version
			file @name do
				template_file = Pathname.new(template)
				content = template_file.read
				token_replacements.each do |key,value|
					content = content.gsub(/(\$\{#{key}\})/, value.to_s)
				end
				of = Pathname.new(@name)
				of.delete if of.exist?
				File.write(of, content)
			end
			
			desc 'Generate the AssemblyInfo.cs file from the template'
			task :assembly_info => [@name]
			self
		end
		
		def template
			@template_file ||= @name.sub(/\.cs/, '.template.cs')
		end
		
		def token_replacements
			r = {}
			r[:built_on] = Time.now
			r[:product] = product_name
			r[:configuration] = configuration
			r[:company] = company_name
			puts 'token repl: ' + version
			r[:version] = version
			return r
		end
		
		def product_name
			@product_name ||= 'Thor'
		end
		
		def configuration
			@configuration ||= 'Debug'
		end
		
		def company_name
			@company_name ||= 'Narrowstep'
		end
		
		def version
			@version ||= '0.0.0.0'
		end
	end
end