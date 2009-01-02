class Dir
	def self.exists?(path)
		File.directory?(path)
	end
end
