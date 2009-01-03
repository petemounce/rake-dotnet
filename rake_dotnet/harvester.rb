class Harvester
	attr_accessor :files, :target
	def initialize(target)
		@files = Hash.new
		@target = target
	end
	
	def add(glob)
		toAdd = Dir.glob(glob)
		toAdd.each do |a|
			pn = Pathname.new(a)
			@files[pn.basename.to_s] = pn
		end
	end
	
	def harvest
		mkdir_p(@target) unless File.exist?(@target)
		@files.sort.each do |k, v|
			cp(v, @target)
		end
	end
	
	def list
		@files.sort.each do |k, v| 
			puts k + ' -> ' + v
		end
	end
end