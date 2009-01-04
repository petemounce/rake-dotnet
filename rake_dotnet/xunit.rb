#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

module Rake
	class XUnitTask < TaskLib
		attr_accessor :name, :suites_dir, :reports_dir, :options
		# Create an XUnitTask file-task; define a task to run it whose name is :xunit
		def initialize(name=:test, params={}) # :yield: self
			@name = name
			@suites_dir = params[:suites_dir] || 'build/bin/Debug'
			@reports_dir = params[:reports_dir] || 'build/reports'
			@options = params[:options] || {}
			@deps = params[:deps] || []
			yield self if block_given?
			define
		end

		# Create the tasks defined by this task lib.
		def define
			rule(/#{@reports_dir}\/.*\//) do |r|
				suite = r.name.match(/.*\/(Tests\.[\w\.]+)\//)[1]
				testsDll = File.join(@suites_dir, suite + '.dll')
				out_dir = File.join(@reports_dir, suite)
				unless File.exist?(out_dir) && uptodate?(testsDll, out_dir)
					mkdir_p(out_dir) unless File.exist?(out_dir)
					x = XUnit.new(testsDll, out_dir, nil, opts=@options)
					x.run
				end
			end

			directory reports_dir
			
			desc "Generate test reports (which ones, depends on the content of XUNIT_OPTS) inside of each directory specified, where each directory matches a test-suite name (give relative paths) (otherwise, all matching #{suites_dir}/Tests.*.dll) and write reports to #{reports_dir}"
			task @name,[:reports] => [reports_dir] do |t, args|
				reports_list = FileList.new("#{suites_dir}/**/Tests.*.dll").pathmap("#{reports_dir}/%n/")
				args.with_defaults(:reports => reports_list)
				args.reports.each do |r|
					Rake::FileTask[r].invoke
				end
			end
			
			@deps.each do |d|
				task @name => d
			end
		end
	end
end

class XUnit
	attr_accessor :xunit, :testDll, :reports_dir, :opts
	
	def initialize(testDll, reports_dir, xunit=nil, opts={})
		@xunit = xunit || File.join('..', '_library', 'xunit', 'xunit.console.exe')
		@testDll = testDll
		@reports_dir = reports_dir
		@opts = opts
	end
	
	def run
		sh cmd
	end
	
	def cmd
		cmd = "#{exe} #{testDll} #{html} #{xml} #{nunit} #{wait} #{noshadow} #{teamcity}"
	end
	
	def exe
		"\"#{@xunit}\""
	end
	
	def suite
		@testDll.match(/.*\/([\w\.]+)\.dll/)[1]
	end
	
	def testDll
		"\"#{@testDll}\""
	end
	
	def html
		"/html #{@reports_dir}/#{suite}.test-results.html" if @opts[:html]
	end
	
	def xml
		"/xml #{@reports_dir}/#{suite}.test-results.xml" if @opts.has_key?(:xml)
	end
	
	def nunit
		"/nunit #{@reports_dir}/#{suite}.test-results.nunit.xml" if @opts.has_key?(:nunit)
	end

	def wait
		'/wait' if @opts.has_key?(:wait)
	end
	
	def noshadow
		'/noshadow' if @opts.has_key?(:noshadow)
	end
	
	def teamcity
		'/teamcity' if @opts.has_key?(:teamcity)
	end
end
