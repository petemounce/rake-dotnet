require 'Pathname'

class XUnit
	attr_accessor :xunit, :test_dll, :reports_dir, :options
	
	def initialize(test_dll, reports_dir, xunit=nil, options={})
		@xunit = xunit || File.join(TOOLS_DIR, 'xunit', 'xunit.console.exe')
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
