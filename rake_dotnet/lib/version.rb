#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'
require 'pathname'

module Rake
	class NameOutputTask < Rake::TaskLib
		def initialize(name, options)
			@name = name
			@configuration = options[:configuration] || 'Debug'
			@version_txt = options[:version_txt] || File.join(OUT_DIR, 'version.txt')
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
			file = File.join(OUT_DIR,'version.txt') if file.nil?
			if File.exists?(file)
				@version = Pathname.new(file).read.chomp
			else
				@version = '0.0.0.0'
			end
		end
	end
end

class Versioner
	def initialize(template_file=nil)
		tf = template_file || 'version.template.txt'
		template_file = Pathname.new(tf)
		@maj_min = template_file.read.chomp
		@build = ENV['BUILD_NUMBER'] || 0
		@svn_info = SvnInfo.new(:path => '.')
	end
	
	def get
		"#{@maj_min}.#{@build}.#{@svn_info.revision}"
	end
end


