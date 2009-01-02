class File
	def self.read_to_end(path)
		content = ''
		File.open(path, 'r') do |file| 
			while (line = file.gets)
				content += line
			end
		end
		return content
	end
	def self.write(path, content)
		File.open(path, 'w') do |file|
			file.puts content
		end
	end
end
