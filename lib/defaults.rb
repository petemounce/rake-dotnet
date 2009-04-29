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

def regexify(path)
	path.gsub('/', '\/').gsub('.', '\.')
end

def find_tools_dir
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
CLOBBER.include(OUT_DIR)

VERBOSE = ENV['VERBOSE'] ? ENV['VERBOSE'] : false
verbose(VERBOSE)
