#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'pathname'

module Rake
	class FigureOutVersionTask < Rake::TaskLib
		attr_accessor :name
		
		def initialize(name, options) # :yield: self
			init(name, options)
			yield self if block_given?
			define
		end
		
		def init(name, options)
			@name = name
			@tools_dir = options[:tools_dir] || File.join('..','..','_library')
		end

		# Create the tasks defined by this task lib.
		def define
			vt = Pathname.new(@name)
			vt_dir = "#{vt.dirname}"

			directory vt_dir
			
			file @name => [vt_dir] do
				maj_min = template_file.read.chomp
				build = 0
				if ENV['build.number']
					build = ENV['build.number']
				end
				si = SvnInfo.new(:path => '.', :tools_dir => @tools_dir)
				v = "#{maj_min}.#{build}.#{si.revision}"
				File.write(@name, v)
			end
			
			desc 'Generate & store version from major/minor in version.template.txt, ENV[build.number] and svn revision.'
			task :figure_out_version => [@name]
			
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
	
	class NameOutputTask < Rake::TaskLib
		def initialize(name, options)
			@name = name
			@configuration = options[:configuration] || 'Debug'
			@version_txt = options[:version_txt] || File.join('out', 'version.txt')
			@deps = options[:deps] || []
			yield self if block_given?
			define
		end
		
		def define
			Rake::FileTask[@version_txt].invoke #ugh!  without this, the define that sets up the file task, with the version number in it gets 0.0.0.0 because at define-time, version.txt doesn't exist yet
			
			output = rename_to
		
			file output do |f|
				puts 'name: ' + @name
				cp_r(@name, output)
			end
			
			task :name_output => output
			
			@deps.each do |d|
				file output => d
			end
		end
		
		def rename_to
			n = Pathname.new(@name)
			version = get_version(@version_txt)
			if (n.directory?)
				"#{n.basename}-#{@configuration}-v#{version}"
			else
				fn = n.basename.sub(n.extname, '')
				"#{n.dirname}/#{fn}-#{@configuration}-v#{version}.#{n.extname}"
			end			
		end
		
		def get_version(file)
			file = File.join('out','version.txt') if file.nil?
			if File.exists?(file)
				@version = Pathname.new(file).read.chomp
			else
				@version = '0.0.0.0'
			end
		end
	end
end


