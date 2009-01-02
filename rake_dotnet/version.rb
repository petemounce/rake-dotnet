#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

module Rake
	class VersionTask < Rake::TaskLib
		attr_accessor :name
		
		def initialize(name) # :yield: self
			init(name)
			yield self if block_given?
			define
		end
		
		def init(name)
			@name = name
		end

		# Create the tasks defined by this task lib.
		def define
			require 'pathname'
			
			vt = Pathname.new(@name)
			vt_dir = "#{vt.dirname}"

			directory vt_dir
			
			file @name => [vt_dir] do
				maj_min = template_file.read.chomp
				build = 0
				if ENV['build.number']
					build = ENV['build.number']
				end
				si = SvnInfo.new
				v = "#{maj_min}.#{build}.#{si.revision}"
				File.write(@name, v)
			end
			
			desc 'Generate & store version from major/minor in version.template.txt, ENV[build.number] and svn revision.'
			task :version => [@name]
			self
		end
		
		def template_file
			template_file = Pathname.new('version.template.txt')
		end
		
		def get_version()
			vt = Pathname.new(@name)
			vt.read.chomp
		end
	end
end
