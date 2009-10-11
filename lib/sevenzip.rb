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