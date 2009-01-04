#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

module Rake
	class AssemblyInfoTask < Rake::TaskLib
		# Name of the main, top level task.  (default is :asminfo)
		attr_accessor :name, :template_file, :product_name, :configuration, :company_name, :versionTxt

		# Create an AssemblyInfo file-task; define a task to run it whose name is :assembly_info
		def initialize(name, versionTxt='build/version.txt') # :yield: self
			@name = name
			@versionTxt = versionTxt
			yield self if block_given?
			define
		end

		# Create the tasks defined by this task lib.
		def define
			require 'pathname'
			
			desc 'Generate the AssemblyInfo.cs file from the template'
			task :assembly_info
			
			file @name => [@versionTxt] do
				template_file = Pathname.new(template)
				content = template_file.read
				token_replacements.each do |key,value|
					content = content.gsub(/(\$\{#{key}\})/, value.to_s)
				end
				of = Pathname.new(@name)
				of.delete if of.exist?
				File.write(of, content)
			end
			
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
			r[:version] = version
			return r
		end
		
		def product_name
			@product_name ||= 'NRWS rake_dotnet'
		end
		
		def configuration
			@configuration ||= 'Debug'
		end
		
		def company_name
			@company_name ||= 'NRWS'
		end
		
		def version
			vt = Pathname.new(@versionTxt)
			@version = vt.read.chomp
		end
	end
end