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
CLEAN.include("#{SRC_DIR}/**/AssemblyInfo.cs")
CLEAN.include("#{SRC_DIR}/**/AssemblyInfo.vb")
CLEAN.include('version.txt')
CLEAN.include("#{SRC_DIR}/**/#{CONFIGURATION}")
CLEAN.include("#{SRC_DIR}/**/Debug")
CLEAN.include("#{SRC_DIR}/**/Release")

task :clobber do
	rm_rf OUT_DIR
end

Bin_out = File.join(OUT_DIR, 'bin')
