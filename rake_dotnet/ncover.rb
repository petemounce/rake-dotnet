class NCover
	def initialize(report_path, dllToRun, dllsToProfile)
		@ncover = File.join(TOOLS_DIR, 'ncover', 'x86', 'ncover.console.exe')
		@dllToRun = dllToRun
		@dllsToProfile = ''
		dllsToProfile.each do |dll|
			f = File.split(dll)[1]
			f.slice(/(.*)\.dll/)
			@dllsToProfile += f + ';'
		end
		@dllsToProfile = @dllsToProfile.chop
		ofname = File.split(dllToRun)[1].sub(/(\.dll)/, '') + '.coverage.xml'
		@output_file = File.join(report_path, ofname)
	end
	
	def cmdToRun
		x = XUnit.new(@dllToRun, {})
		x.cmd
	end
	
	def cmd
		"\"#{@ncover}\" #{cmdToRun} //a #{@dllsToProfile} //x #{@output_file}"
	end
	
	def run
		sh cmd
	end
end
