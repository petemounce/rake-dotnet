class XUnit
	def initialize(lib_path, testDll, reports)
		@xunit = File.join(lib_path, 'xunit', 'xunit.console.exe')
		@testDll = testDll
		@reports = reports
	end
	
	def run
		sh cmd
	end
	
	def cmd
		cmd = "\"#{@xunit}\" \"#{@testDll}\" #{html}"
	end
	
	def html
		"/html #{@reports[:html]}" if @reports[:html]
	end
end
