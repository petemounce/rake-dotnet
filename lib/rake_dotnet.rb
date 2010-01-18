#!/usr/bin/env ruby

#--

# Copyright 2003, 2004, 2005, 2006, 2007, 2008, 2009 by Peter Mounce (pete@neverrunwithscissors.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

#++
#
# = Rake DotNet -- A collection of custom tasks for .NET build automation
#
# This is the main file for Rake DotNet custom tasks.  Normally it is referenced
# as a library via a require statement, but it can be distributed
# independently as an application.

require 'rake'
require 'rake/tasklib'
require 'rake/clean'
require 'pathname'

desc "Displays this message; a list of tasks"
task :help do
	taskHash = Hash[*(`rake.cmd -T`.split(/\n/).collect { |l| l.match(/rake (\S+)\s+\#\s(.+)/).to_a }.collect { |l| [l[1], l[2]] }).flatten]

	indent = "                          "

	puts "rake #{indent}#Runs the 'default' task"

	taskHash.each_pair do |key, value|
		if key.nil?
			next
		end
		puts "rake #{key}#{indent.slice(0, indent.length - key.length)}##{value}"
	end
end

module RakeDotNet


def RakeDotNet::regexify(path)
	path.gsub('/', '\/').gsub('.', '\.')
end

def RakeDotNet::find_tools_dir
	shared = File.join(PRODUCT_ROOT, '..', '3rdparty')
	owned = File.join(PRODUCT_ROOT, '3rdparty')
	if File.exist?(shared)
		return shared
	end
	if File.exist?(owned)
		return owned
	end
end

# Setting constants like this allows you to do things like 'rake compile CONFIGURATION=Release' to specify their values
# By default, we assume that this Rakefile lives in {PRODUCT_ROOT}/build, and that this is the working directory
PRODUCT_ROOT = ENV['PRODUCT_ROOT'] ? ENV['PRODUCT_ROOT'] : '..'
SRC_DIR = ENV['SRC_DIR'] ? ENV['SRC_DIR'] : File.join(PRODUCT_ROOT, 'src')
TOOLS_DIR = ENV['TOOLS_DIR'] ? ENV['TOOLS_DIR'] : find_tools_dir
CONFIGURATION = ENV['CONFIGURATION'] ? ENV['CONFIGURATION'] : 'Debug'
MSBUILD_VERBOSITY = ENV['MSBUILD_VERBOSITY'] ? ENV['MSBUILD_VERBOSITY'] : 'm'
OUT_DIR = ENV['OUT_DIR'] ? ENV['OUT_DIR'] : 'out'

# clean will remove intermediate files (like the output of msbuild; things in the src tree)
# clobber will remove build-output files (which will all live under the build tree)
CLEAN.exclude('**/core') # core files are a Ruby/*nix thing - dotNET developers are unlikely to generate them.
CLEAN.include("#{SRC_DIR}/**/obj")
CLEAN.include("#{SRC_DIR}/**/bin")
CLEAN.include("#{SRC_DIR}/**/AssemblyInfo.cs")
CLEAN.include("#{SRC_DIR}/**/AssemblyInfo.vb")
CLEAN.include('version.txt')
CLOBBER.include(OUT_DIR)

VERBOSE = ENV['VERBOSE'] ? ENV['VERBOSE'] : false
verbose(VERBOSE)


class Cli
	attr_accessor :bin, :search_paths

	def initialize(params={})
		@bin = params[:exe] || nil
		@exe_name = params[:exe_name] #required for inferring path

		# guessable / defaultable
		@search_paths = params[:search_paths] || []
		@search_paths << nil # use the one that will be found in %PATH%
	end

	def exe
		return @bin unless @bin.nil?

		@bin = "#{search_for_exe}"

		return @bin
	end

	def cmd
		return "\"#{exe}\""
	end

	def search_for_exe
		@search_paths.each do |sp|
			if sp.nil?
				return @exe_name #because we add bare exe as last element in array
			else
				path = File.join(sp, @exe_name)
				return File.expand_path(path) if File.exist? path
			end
		end
		raise(ArgumentError, "No executable found in search-paths or system-PATH", caller)
	end
end


class BcpCmd < Cli
	attr_accessor :keep_identity_values, :keep_null_values, :wide_character_type, :field_terminator, :native_type
	attr_accessor :direction, :database, :table, :schema, :file

	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'sql')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '100', 'tools', 'binn')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '90', 'tools', 'binn')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '80', 'tools', 'binn')
		super(params.merge({:exe_name=>'bcp.exe', :search_paths=>sps}))

		unless params[:trusted].nil?
			@trusted = params[:trusted]
		else
			@trusted = true
		end
		unless @trusted
			@user = params[:user] || DB_USER
			@password = params[:password] || DB_PASSWORD
		end

		@server = params[:server] || DB_SERVER

		@database = params[:database] unless params[:database].nil?
		@schema = params[:schema] || 'dbo'
		@table = params[:table] unless params[:table].nil?
		@direction = params[:direction] unless params[:direction].nil?
		@file = params[:file] unless params[:file].nil?
	end

	def credentials
		if @trusted
			return '-T'
		else
			return "-U \"#{@user}\" -P \"#{@password}\""
		end
	end

	def server
		return "-S \"#{@server}\""
	end

	def direction
		return @direction.to_s
	end

	def db_object
		return "[#{@database}].[#{@schema}].[#{@table}]"
	end

	def path
		return '"' + File.expand_path(@file).gsub('/', '\\') + '"'
	end

	def keep_identity_values
		return '-E' unless @keep_identity_values.nil?
	end

	def keep_null_values
		return '-k' unless @keep_null_values.nil?
	end

	def wide_character_type
		return '-w' unless @wide_character_type.nil?
	end

	def field_terminator
		return "-t '#{@field_terminator}'" unless @field_terminator.nil?
	end

	def native_type
		return '-n' unless @native_type.nil?
	end

	def cmd
		return "#{exe} #{db_object} #{direction} #{path} #{server} #{credentials} #{keep_identity_values} #{keep_null_values} #{wide_character_type} #{field_terminator} #{native_type}"
	end

	def revert_optionals
		@keep_identity_values = nil
		@keep_null_values = nil
		@wide_character_type = nil
		@field_terminator = nil
		@native_type = nil
		@direction = nil
	end

	def run
		puts cmd if VERBOSE == true
		sh cmd
		revert_optionals
	end
end


class SqlCmd < Cli
	attr_accessor :input_file, :query, :database
	
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'sql')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '100', 'tools', 'binn')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '90', 'tools', 'binn')
		sps << File.join(ENV['PROGRAMFILES'], 'Microsoft SQL Server', '80', 'tools', 'binn')
		super(params.merge({:exe_name=>'sqlcmd.exe', :search_paths=>sps}))

		unless params[:trusted].nil?
			@trusted = params[:trusted]
		else
			@trusted = true
		end
		unless @trusted
			@user = params[:user] || DB_USER
			@password = params[:password] || DB_PASSWORD
		end
		@server = params[:server] || DB_SERVER

		#optionals and runtime settable
		@input_file = params[:input_file]
		@query = params[:query]
	end

	def credentials
		if @trusted
			return '-E'
		else
			return "-U \"#{@user}\" -P \"#{@password}\""
		end
	end

	def server
		return "-S \"#{@server}\""
	end

	def database
		return "-d \"#{@database}\"" unless @database.nil?
	end

	def input_file
		unless @input_file.nil?
			path = File.expand_path(@input_file).gsub('/', "\\")
			return "-i \"#{path}\""
		end
		return ''
	end

	def query
		return "-Q \"#{@query}\"" unless @query.nil?
	end

	def cmd
		return "#{exe} #{server} #{credentials} #{database} #{input_file} #{query}"
	end

	def run
		puts cmd if VERBOSE == true
		sh cmd
		revert_optionals
	end

	def revert_optionals
		@query = nil
		@input_file = nil
	end
end


class AssemblyInfoTask < Rake::TaskLib
	attr_accessor :product_name, :configuration, :company_name, :version

	def initialize(params={})
		@src_dir = params[:src_dir] || SRC_DIR
		yield self if block_given?
		define
	end

	def define
		src_dir_regex = RakeDotNet::regexify(@src_dir)
		rule(/#{src_dir_regex}\/[\w\.\d]+\/Properties\/AssemblyInfo.cs/) do |r|
			dir = Pathname.new(r.name).dirname
			mkdir_p dir
			nextdoor = Pathname.new(r.name + '.template')
			common = Pathname.new(File.join(@src_dir, 'AssemblyInfo.cs.template'))
			if (nextdoor.exist?)
				generate(nextdoor, r.name)
			elsif (common.exist?)
				generate(common, r.name)
			end
		end

		rule(/#{src_dir_regex}\/[\w\.\d]+\/My Project\/AssemblyInfo.vb/) do |r|
			dir = Pathname.new(r.name).dirname
			mkdir_p dir
			nextdoor = Pathname.new(r.name + '.template')
			common = Pathname.new(File.join(@src_dir, 'AssemblyInfo.vb.template'))
			if (nextdoor.exist?)
				generate(nextdoor, r.name)
			elsif (common.exist?)
				generate(common, r.name)
			end
		end

		desc 'Generate the AssemblyInfo.cs file from the template closest'
		task :assembly_info do |t|
			Pathname.new(@src_dir).entries.each do |e|
				asm_info = asm_info_to_generate(e)
				Rake::FileTask[asm_info].invoke unless asm_info.nil?
			end
		end

		self
	end

	def generate(template_file, destination)
		content = template_file.read
		token_replacements.each do |key, value|
			content = content.gsub(/(\$\{#{key}\})/, value.to_s)
		end
		of = Pathname.new(destination)
		of.delete if of.exist?
		of.open('w') { |f| f.puts content }
	end

	def asm_info_to_generate pn_entry
		if (pn_entry == '.' || pn_entry == '..' || pn_entry == '.svn')
			return nil
		end
		if (pn_entry == 'AssemblyInfo.cs.template' || pn_entry == 'AssemblyInfo.vb.template')
			return nil
		end

		proj = FileList.new("#{@src_dir}/#{pn_entry}/*.*proj").first
		return nil if proj.nil?

		proj_ext = Pathname.new(proj).extname
		path =
				case proj_ext
					when '.csproj' then
						File.join(@src_dir, pn_entry, 'Properties', 'AssemblyInfo.cs')
					when '.vbproj' then
						File.join(@src_dir, pn_entry, 'My Project', 'AssemblyInfo.vb')
					else
						nil
				end
		return path
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
		@product_name ||= PRODUCT_NAME
	end

	def configuration
		@configuration ||= CONFIGURATION
	end

	def company_name
		@company_name ||= COMPANY_NAME
	end

	def version
		@version ||= Versioner.new.get
	end
end


class FxCopTask < Rake::TaskLib
	attr_accessor :dll_list, :suites_dir

	def initialize(params={})
		@product_name = params[:product_name] || PRODUCT_NAME
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports')
		@name = params[:name] || File.join(@report_dir, @product_name + '.fxcop')
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@dll_list = FileList.new
		@deps = params[:deps] || []
		@fxcop_options = params[:fxcop_options] || {}
		if @fxcop_options[:apply_out_xsl].nil? || @fxcop_options[:apply_out_xsl] == false
			@name += '.xml'
		else
			@name += '.html'
		end
		@fxcop_options[:out_file] = @name if @fxcop_options[:out_file].nil?

		yield self if block_given?
		define
	end

	def define
		@deps.each do |d|
			task :fxcop => d
		end

		directory @report_dir

		file @name => [@report_dir] do |f|
			runner = FxCop.new(@dll_list, @fxcop_options)
			runner.run
		end

		task :fxcop, [:include_globs, :exclude_globs] do |t, args|
			args.with_defaults(:include_globs => ["#{@suites_dir}/**/*#{@product_name}*.dll", "#{@suites_dir}/**/*#{@product_name}*.exe"])
			args.include_globs.each do |g|
				@dll_list.include g
			end
			args.with_defaults(:exclude_globs => ["#{@suites_dir}/*Tests*.dll", "#{@suites_dir}/*.vshost.exe"])
			args.exclude_globs.each do |g|
				@dll_list.exclude g
			end
			Rake::FileTask[@name].invoke
		end

		task :clobber_fxcop, [:globs] do |t, args|
			rm_rf @report_dir
		end

		self
	end

	self
end

class FxCopCmd
	attr_accessor :dlls, :out_file, :out_xsl, :apply_out_xsl, :dependencies_path, :summary, :verbose, :echo_to_console, :xsl_echo_to_console, :ignore_autogen, :culture

	def initialize(dlls, params={})
		@dlls = dlls

		@exe_dir = params[:fxcop_exe_dir] || File.join(TOOLS_DIR, 'fxcop')
		@exe = params[:fxcop_exe] || File.join(@exe_dir, 'fxcopcmd.exe')

		@apply_out_xsl = params[:apply_out_xsl]
		@culture = params[:culture]
		@dependencies_path = params[:dependencies_path]
		@echo_to_console = params[:echo_to_console]
		@ignore_autogen = params[:ignore_autogen] || true
		@out_file = params[:out_file]
		@out_xsl = File.join(@exe_dir, 'Xml', params[:out_xsl]) unless params[:out_xsl].nil?
		@summary = params[:summary]
		@verbose = params[:verbose]
		@xsl_echo_to_console = params[:xsl_echo_to_console]

		yield self if block_given?
	end

	def console
		'/console' if @echo_to_console || @out_file.nil?
	end

	def files_to_analyse
		list = ''
		@dlls.each do |dll|
			list += "/file:\"#{dll}\" "
		end
		list = list.chop
	end

	def out_file
		"/out:\"#{@out_file}\"" if @out_file
	end

	def out_xsl
		"/outxsl:\"#{@out_xsl}\"" if @out_xsl
	end

	def apply_out_xsl
		"/applyoutxsl" if @apply_out_xsl
	end

	def cmd
		"\"#{@exe}\" #{files_to_analyse} #{console} #{out_file} #{out_xsl} #{apply_out_xsl}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
		puts "##teamcity[importData type='FxCop' path='#{File.expand_path(@out_file)}']" if ENV['BUILD_NUMBER']
	end
end


class HarvestOutputTask < Rake::TaskLib
	def initialize(params={})
		@src_path = params[:src_path] || File.join(PRODUCT_ROOT, 'src')
		@target_path = params[:target_path] || Bin_out
		@deps = params[:deps] || []
		@configuration = params[:configuration] || CONFIGURATION
		@glob = params[:glob] || "#{@src_path}/*"

		yield self if block_given?
		define
	end

	def define
		directory @target_path

		desc "Harvest specified libraries (or all matching #{@glob}) to #{@target_path}"
		task :harvest_output, [:to_harvest_list] => @target_path do |t, args|
			list = FileList.new
			@glob.each do |g|
				list.include(g)
			end
			args.with_defaults(:to_harvest_list => list)
			args.to_harvest_list.each do |entry|
				pn = Pathname.new(entry)
				if pn.directory?
					output = FileList.new
					#TODO: distinguish between web and class and console output
					output.include("#{entry}/bin/#{@configuration}/*")
					output.include("#{entry}/bin/*")
					output.each do |o|
						o_pn = Pathname.new(o)
						to_pn = Pathname.new("#{@target_path}")
						if (o_pn.directory?)
							cp_r(o, to_pn) unless o_pn.to_s.match(/#{@configuration}$/)
						else
							cp(o, to_pn)
						end
					end
				end
			end
		end

		@deps.each do |d|
			task :harvest => d
		end

		self
	end
end

class HarvestWebApplicationTask < Rake::TaskLib
	def initialize(params={})
		@src_path = params[:src_path] || File.join(PRODUCT_ROOT, 'src')
		@target_path = params[:target_path] || OUT_DIR
		@deps = params[:deps] || []
		@glob = params[:glob] || "**/*.Site"

		yield self if block_given?
		define
	end

	def define
		out_dir_regex = RakeDotNet::regexify(@target_path)

		odr = /#{out_dir_regex}\/([\w\.-_ ]*Site)\//
		rule(odr) do |r|
			harvest(r.name, odr)
		end
		
		desc "Harvest specified web-applications (or all matching #{@src_path}/#{@glob}) to #{@target_path}"
		task :harvest_webapps, [:web_app_list] => @target_path do |t, args|
			list = FileList.new("#{@src_path}/#{@glob}")
			args.with_defaults(:web_app_list => list)
			args.web_app_list.each do |w|
				pn = Pathname.new(w)
				out = File.join(@target_path, pn.basename) + '/'
				Rake::FileTask[out].invoke
			end
		end

		@deps.each do |d|
			task :harvest_webapps => d
		end

		self
	end

	def harvest(path, regex)
		web_app_name = path.match(regex)[1]
		src = File.join(@src_path, web_app_name)
		if (File.exist?("#{src}/.svn"))
			svn = SvnExport.new({:src=>src, :dest=>path})
			svn.run
			cp_r(File.join(src, 'bin'), path)
		else
			cp_r src, path
		end
		FileList.new("#{path}**/obj").each do |e|
			rm_rf e if File.exist? e
		end
	end
end

class Harvester
	attr_accessor :files, :target

	def initialize
		@files = Hash.new
	end

	def add(glob)
		toAdd = Dir.glob(glob)
		toAdd.each do |a|
			pn = Pathname.new(a)
			@files[pn.basename.to_s] = pn
		end
	end

	def harvest(target)
		mkdir_p(target) unless File.exist?(target)
		@files.sort.each do |k, v|
			cp(v, target)
		end
	end

	def list
		@files.sort.each do |k, v|
			puts k + ' -> ' + v
		end
	end
end


class MsBuildTask < Rake::TaskLib
	attr_accessor :src_dir, :verbosity, :working_dir

	def initialize(params={})
		#TODO: Support for arbitrary properties, not just configuration.  For example, TreatWarningsAsErrors, WarningLevel.
		@configuration = params[:configuration] || CONFIGURATION
		@src_dir = params[:src_dir] || SRC_DIR
		@verbosity = params[:verbosity] || MSBUILD_VERBOSITY || 'm'
		@working_dir = params[:working_dir] || '.'
		@deps = params[:deps] || []
		@buildable_projects = ['.csproj', '.vbproj', '.wixproj']
		@properties = {:Configuration => @configuration, :TreatWarningsAsErrors => true, :WarningLevel => 4, :BuildInParallel => true}.merge(params[:properties] || {})

		yield self if block_given?
		define
	end

	def define
		# most project types put output into bin/{configuration}
		rule(/#{src_dir_regex}\/[\w\.]+\/bin\/#{@configuration}\/[\w\.]+\.(?:dll|exe)/) do |r|
			pn = Pathname.new(r.name)
			name = pn.basename.to_s.sub('.dll', '')
			project = FileList.new("#{@src_dir}/#{name}/#{name}.*proj").first
			mb = MsBuildCmd.new(project, @properties, ['Build'], verbosity, @working_dir)
			mb.run
		end

		# web application projects put output into /bin
		rule(/#{src_dir_regex}\/[\w\.]+\/bin\/[\w\.]+\.dll/) do |r|
			pn = Pathname.new(r.name)
			name = pn.basename.to_s.sub('.dll', '')
			project = FileList.new("#{@src_dir}/#{name}/#{name}.*proj").first
			mb = MsBuildCmd.new(project, @properties, ['Build'], verbosity, @working_dir)
			mb.run
		end

		desc "Compile the specified projects (give relative paths) (otherwise, all matching src/**/*.*proj)"
		task :compile, [:projects] do |t, args|
			project_list = FileList.new("#{src_dir}/**/*.*proj")
			args.with_defaults(:projects => project_list)
			args.projects.each do |p|
				pn = Pathname.new(p)
				# TODO: Figure out which type of project we are so we can invoke the correct rule, with the correct output extension
				dll = File.join(pn.dirname, 'bin', @configuration, pn.basename.sub(pn.extname, '.dll'))
				Rake::FileTask[dll].invoke if @buildable_projects.include?(pn.extname)
			end
		end

		@deps.each do |d|
			task :compile => d
		end

		self
	end

	def src_dir_regex
		RakeDotNet::regexify(@src_dir)
	end

	def figure_out_project_type(project_pathname)
		# TODO.
	end
end

class MsBuildCmd
	attr_accessor :project, :properties, :targets, :verbosity

	def initialize(project='default.proj', properties={}, targets=[], verbosity='n', working_dir=nil)
		@project = project
		@properties = properties
		@targets = targets
		@verbosity = verbosity
		@working_dir = working_dir
		@exe = '"' + File.join(ENV['windir'].dup, 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe') + '"'
	end

	def cmd
		"#{@exe} #{project} /maxcpucount /v:#{@verbosity} /p:#{properties} /t:#{targets}"
	end

	def run
		if @working_dir
			chdir(@working_dir) do
				puts cmd if VERBOSE
				sh cmd
			end
		end
	end

	def project
		"\"#{@project}\""
	end

	def targets
		@targets.join(';')
	end

	def properties
		p = []
		@properties.each {|key, value| p.push("#{key}=#{value}") }
		p.join(';')
	end
end


class NCoverTask < Rake::TaskLib
	attr_accessor :profile_options, :reporting_options

	def initialize(params={})
		@product_name = params[:product_name] || PRODUCT_NAME
		@bin_dir = params[:bin_dir] || File.join(OUT_DIR, 'bin')
		@report_dir = params[:report_dir] || File.join(OUT_DIR, 'reports', 'ncover')
		@deps = params[:deps] || []
		tool_defaults = {:arch => ENV['PROCESSOR_ARCHITECTURE']}
		@profile_options = tool_defaults.merge(params[:profile_options] || {})
		@reporting_options = tool_defaults.merge(params[:reporting_options] || {})

		yield self if block_given?
		define
	end

	def define
		@deps.each do |d|
			task :ncover_profile => d
		end

		directory @report_dir

		reports_dir_regex = RakeDotNet::regexify(@report_dir)
		rule(/#{reports_dir_regex}\/.*\.coverage\.xml/) do |r|
			dll_to_execute = r.name.sub(/#{@report_dir}\/(.*)\.coverage\.xml/, "#{@bin_dir}/\\1.dll")
			nc = NCoverConsoleCmd.new(@report_dir, dll_to_execute, @profile_options)
			nc.run
		end

		desc "Generate ncover coverage XML, one file per test-suite that exercises your product"
		task :ncover_profile, [:dlls_to_run] => [@report_dir] do |t, args|
			dlls_to_run_list = FileList.new
			dlls_to_run_list.include("#{@bin_dir}/**/*#{@product_name}*Tests*.dll")
			dlls_to_run_list.include("#{@bin_dir}/**/*#{@product_name}*Tests*.exe")
			args.with_defaults(:dlls_to_run => dlls_to_run_list)
			args.dlls_to_run.each do |d|
				dll_to_run = Pathname.new(d)
				cf_name = dll_to_run.basename.sub(dll_to_run.extname, '.coverage.xml')
				coverage_file = File.join(@report_dir, cf_name)
				Rake::FileTask[coverage_file].invoke
			end

		end

		desc "Generate ncover coverage report(s), on all coverage files, merged together"
		task :ncover_reports => [:ncover_profile] do
			# ncover lets us use *.coverage.xml to merge together files
			include = [File.join(@report_dir, '*.coverage.xml')]
			@reporting_options[:name] = 'merged'
			ncr = NCoverReportingCmd.new(@report_dir, include, @reporting_options)
			ncr.run
		end

		task :clobber_ncover do
			rm_rf @report_dir
		end

		self
	end
end

class NCoverConsoleCmd
	def initialize(report_dir, dll_to_execute, params)
		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.console.exe')
		@dll_to_execute = dll_to_execute
		ofname = File.split(dll_to_execute)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_dir, ofname)
		@exclude_assemblies_regex = params[:exclude_assemblies_regex] || ['.*Tests.*']
		@exclude_assemblies_regex.push('ISymWrapper')
		@working_dir = params[:working_dir] || Pathname.new(@dll_to_execute).dirname
	end

	def cmdToRun
		x = XUnitConsoleCmd.new(@dll_to_execute, '', nil, {})
		x.cmd
	end

	def bi
		"//bi #{Versioner.new.get.to_s}"
	end

	def working_dir
		"//w #{@working_dir}"
	end

	def exclude_assemblies
		if @exclude_assemblies_regex.instance_of?(Array)
			return '//eas ' + @exclude_assemblies_regex.join(';')
		end
		return '//eas ' + @exclude_assemblies_regex if @exclude_assemblies_regex.instance_of?(String)
	end

	def cmd
		"\"#{@exe}\" #{cmdToRun} //x #{@output_file} #{exclude_assemblies} #{bi} #{working_dir}"
	end

	def run
		puts cmd if VERBOSE
		sh cmd
	end
end

class NCoverReportingCmd
	def initialize(report_dir, coverage_files, params)
		@report_dir = report_dir
		@coverage_files = coverage_files || []

		params ||= {}
		arch = params[:arch] || ENV['PROCESSOR_ARCHITECTURE']
		@exe = params[:ncover_reporting_exe] || File.join(TOOLS_DIR, 'ncover', arch, 'ncover.reporting.exe')

		# required
		@reports = params[:reports] || ['Summary', 'UncoveredCodeSections', 'FullCoverageReport']
		@output_path = File.join(@report_dir)

		# optional
		@sort_order = params[:sort] || 'CoveragePercentageAscending'
		@project_name = params[:project_name] || PRODUCT_NAME
	end

	def coverage_files
		list = ''
		@coverage_files.each do |cf|
			list += "\"#{cf}\" "
		end
		list
	end

	def build_id
		"//bi #{Versioner.new.get.to_s}"
	end

	def output_reports
		cmd = ''
		@reports.each do |r|
			cmd += "//or #{r} "
		end
		return cmd
	end

	def output_path
		"//op \"#{@output_path}\""
	end

	def sort_order
		"//so #{@sort_order}"
	end

	def project_name
		"//p #{@project_name}" unless @project_name.nil?
	end

	def cmd
		"\"#{@exe}\" #{coverage_files} #{build_id} #{output_reports} #{output_path} #{sort_order} #{project_name}"
	end

	def run
		sh cmd
	end
end


class RDNPackageTask < Rake::TaskLib
	attr_accessor :targets

	def initialize(name, params={})
		@name = name
		@out_dir = params[:out_dir] || OUT_DIR
		@deps = params[:deps] || []
		@configuration = params[:configuration] || CONFIGURATION
		globs = params[:globs] || []
		@targets = FileList.new globs

		yield self if block_given?
		define
	end

	def define
		pkg = File.join(@out_dir, 'pkg')
		pkg_root = File.join(pkg, @name)

		directory pkg # out/pkg
		directory pkg_root # out/pkg/bin

		package_file = pkg_root + '.zip'
		package_file_regex = RakeDotNet::regexify(package_file)

		@deps.each do |d|
			file package_file => d
			task :package => d
		end

		pkg_root_regex = RakeDotNet::regexify(pkg_root)
		rule(/#{pkg_root_regex}\.zip/) do |r|
			run_package
		end

		rule(/#{pkg_root_regex}-#{@configuration}\.zip/) do |r|
			run_package
		end
		rule(/#{pkg_root_regex}-#{@configuration}-v\d+\.\d+\.\d+\.\d+\.zip/) do |r|
			run_package
		end

		def run_package(configuration, version)
			@targets.each do |t|
				f = Pathname.new(t)
				if f.directory?
					cp_r f, pkg_root
				else
					cp f, pkg_root
				end
			end
			snipped = pkg_root.sub(pkg + '/', '')
			sz = SevenZipCmd.new(package_file)
			chdir pkg_root do
				sz.run_add
			end
		end

		directory @out_dir

		desc "Generate zip'd packages for all package-tasks"
		task :package => [@out_dir, pkg, pkg_root, package_file]

		desc "Generate zip'd package for #{@name}"
		task "package_#{@name}".to_sym => [@out_dir, pkg, pkg_root, package_file]

		desc "Delete all packages"
		task :clobber_package do
			rm_rf pkg
		end

		task :clobber => :clobber_package

		desc "Delete all packages and recreate them"
		task :repackage => [:clobber_package, :package]

		self
	end
end


class SevenZipCmd
	def initialize(archive_name, opts={})
		arch = ENV['PROCESSOR_ARCHITECTURE'] || 'AMD64'
		bin = arch == 'x86' ? '7za.exe' : '7z.exe'
		@exe = opts[:sevenzip] || File.expand_path(File.join(TOOLS_DIR, '7zip', arch, bin))
		@archive_name = File.expand_path(archive_name)
		@params = opts

		yield self if block_given?
	end

	def cmd_add
		"#{exe} a #{archive_name} #{file_names}"
	end

	def run_add
		puts cmd_add if VERBOSE
		sh cmd_add
	end

	def cmd_extract
		"#{exe} x -y #{out_dir} #{archive_name} #{file_names}"
	end

	def run_extract
		puts cmd_extract if VERBOSE
		sh cmd_extract
	end

	def out_dir
		od = @params[:out_dir]
		"-o#{File.expand_path(od)}" unless @params[:out_dir].nil?
	end

	def archive_name
		"\"#{@archive_name}\""
	end

	def file_names
		fns = @params[:file_names]
		if fns.is_a? String
			"\"#{fns}\""
		elsif fns.is_a? Array
			list = ''
			fns.each do |fn|
				list += "\"#{File.expand_path(fn)}\" "
			end
			list.chop
		end
	end

	def exe
		"\"#{@exe}\""
	end
end


class SvnCmd < Cli
	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'svn', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'subversion', 'bin')
		sps << File.join(ENV['PROGRAMFILES'], 'svn', 'bin')
		super(params.merge({:exe_name=>'svn.exe',:search_paths=>sps}))
	end

	def cmd
		return super
	end
end

class SvnExport < SvnCmd
	def initialize(params={})
		super
		raise(ArgumentError, "src parameter was missing", caller) if params[:src].nil?
		raise(ArgumentError, "dest parameter was missing", caller) if params[:dest].nil?
		@src = params[:src]
		@dest = params[:dest]
	end

	def src
		return "\"#{File.expand_path(@src)}\""
	end

	def dest
		return "\"#{File.expand_path(@dest)}\""
	end

	def cmd
		return "#{super} export #{src} #{dest}"
	end

	def run
		puts cmd if VERBOSE==true
		sh cmd
	end
end

class SvnInfo < SvnCmd
	def initialize(params={})
		super
		@path = params[:path] || '.'
	end

	def cmd
		"#{super} info #{path}"
	end

	def revision
		puts cmd if VERBOSE
		out = `#{cmd}`
		out.match(/Revision: (\d+)/)[1]
	end

	def path
		"\"#{@path}\""
	end
end


class Versioner
	def initialize(template_file=nil, opts={})
		tf_path = template_file || 'version.template.txt'
		@tf = Pathname.new(tf_path)
		@vf = Pathname.new(tf_path.sub('.template', ''))
	end

	def get
		return @vf.read.chomp if @vf.exist?

		v = "#{maj_min}.#{build}.#{revision}"
		@vf.open('w') {|f| f.write(v) }
		return v
	end

	def maj_min
		return @tf.read.chomp
	end

	def build
		bn = ENV['BUILD_NUMBER']
		return 0 if bn == nil || !bn.match(/\d+/)
		return bn
	end

	def revision
		if (Pathname.new('.svn').exist?)
			return SvnInfo.new(:path => '.').revision
		else
			# TODO: return something numeric but sane for non-numeric revision numbers (eg DVCSs)
			return '0' # YYYYMMDD is actually invalid for a {revision} number.
		end
	end
end

Version_txt = 'version.txt'
file Version_txt do
	Versioner.new.get
end
task :version => Version_txt
task :assembly_info => Version_txt


class XUnitTask < Rake::TaskLib
	attr_accessor :suites_dir, :reports_dir, :options

	def initialize(params={}) # :yield: self
		@suites_dir = params[:suites_dir] || File.join(OUT_DIR, 'bin')
		@reports_dir = params[:reports_dir] || File.join(OUT_DIR, 'reports')
		@options = params[:options] || {}
		@deps = params[:deps] || []

		yield self if block_given?
		define
	end

	# Create the tasks defined by this task lib.
	def define
		@deps.each do |d|
			task :xunit => d
		end

		rule(/#{@reports_dir}\/.*Tests.*\//) do |r|
			suite = r.name.match(/.*\/(.*Tests)\//)[1]
			testsDll = File.join(@suites_dir, suite + '.dll')
			out_dir = File.join(@reports_dir, suite)
			unless File.exist?(out_dir) && uptodate?(testsDll, out_dir)
				mkdir_p(out_dir) unless File.exist?(out_dir)
				x = XUnitConsoleCmd.new(testsDll, out_dir, nil, options=@options)
				x.run
			end
		end

		directory @reports_dir

		desc "Generate test reports (which ones, depends on the content of XUNIT_OPTS) inside of each directory specified, where each directory matches a test-suite name (give relative paths) (otherwise, all matching #{@suites_dir}/*Tests.*.dll) and write reports to #{@reports_dir}"
		task :xunit, [:reports] => [@reports_dir] do |t, args|
			reports_list = FileList.new("#{@suites_dir}/**/*Tests*.dll").pathmap("#{@reports_dir}/%n/")
			args.with_defaults(:reports => reports_list)
			args.reports.each do |r|
				Rake::FileTask[r].invoke
			end
		end

		task :xunit_clobber do
			rm_rf(@reports_dir)
		end

		self
	end
end

class XUnitConsoleCmd
	attr_accessor :xunit, :test_dll, :reports_dir, :options

	def initialize(test_dll, reports_dir, xunit=nil, options={})
		x86exe = File.join(TOOLS_DIR, 'xunit', 'xunit.console.x86.exe')
		x64exe = File.join(TOOLS_DIR, 'xunit', 'xunit.console.exe')
		path_to_xunit = x64exe
		if File.exist? x86exe
			path_to_xunit = x86exe
		end
		@xunit = xunit || path_to_xunit
		@xunit = File.expand_path(@xunit)
		@test_dll = File.expand_path(test_dll)
		@reports_dir = File.expand_path(reports_dir)
		@options = options
	end

	def run
		test_dir = Pathname.new(test_dll).dirname
		chdir test_dir do
			puts cmd if VERBOSE
			sh cmd
		end
	end

	def cmd
		cmd = "#{exe} #{test_dll} #{html} #{xml} #{nunit} #{wait} #{noshadow} #{teamcity}"
	end

	def exe
		"\"#{@xunit}\""
	end

	def suite
		@test_dll.match(/.*\/([\w\.]+)\.dll/)[1]
	end

	def test_dll
		"\"#{@test_dll}\""
	end

	def html
		"/html #{@reports_dir}/#{suite}.test-results.html" if @options.has_key?(:html)
	end

	def xml
		"/xml #{@reports_dir}/#{suite}.test-results.xml" if @options.has_key?(:xml)
	end

	def nunit
		"/nunit #{@reports_dir}/#{suite}.test-results.nunit.xml" if @options.has_key?(:nunit)
	end

	def wait
		'/wait' if @options.has_key?(:wait)
	end

	def noshadow
		'/noshadow' if @options.has_key?(:noshadow)
	end

	def teamcity
		'/teamcity' if @options.has_key?(:teamcity)
	end
end


end


