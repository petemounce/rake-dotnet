require 'rake'

CONFIGURATION = ENV['CONFIGURATION'] || 'Debug'

msbuild = File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe')
solution = File.join('..','DemoRoot','Demo','Demo.sln')

task :echo do
	puts CONFIGURATION
end

task :clean do
	sh "#{msbuild} /v:m /t:Clean /p:Configuration=#{CONFIGURATION} #{solution}"
end

task :build do
	sh "#{msbuild} /v:m /t:Build /p:Configuration=#{CONFIGURATION} #{solution}"
end

task :default => [:clean, :build, :echo]
