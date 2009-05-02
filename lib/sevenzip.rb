class SevenZip
	def initialize(archive_name, file_names, opts={})
		arch = ENV['PROCESSOR_ARCHITECTURE'] || 'AMD64'
		bin = arch == 'x86' ? '7za.exe' : '7z.exe'
		@exe = opts[:sevenzip] || File.join(TOOLS_DIR, '7zip', arch, bin)
		@archive_name = archive_name
		@file_names = file_names
		
		yield self if block_given?
	end
	
	def cmd_add
		"#{exe} a #{switches} #{archive_name} #{file_names}"
	end
	
	def run_add
		puts cmd_add if VERBOSE
		sh cmd_add
	end
	
	def archive_name
		"\"#{@archive_name}\""
	end
	
	def file_names
		if @file_names.is_a? String
			"\"#{@file_names}\""
		elsif @file_names.is_a? Array
			list = ''
			@file_names.each do |fn|
				list += "\"#{fn}\" "
			end 
			list.chop
		end
	end
	
	def exe
		"\"#{@exe}\""
	end
	
	def switches
	
	end
end
