require 'rake'

msbuild = File.join(ENV['WINDIR'], 'Microsoft.NET', 'Framework', 'v3.5', 'msbuild.exe')
solution = File.join('..','DemoRoot','Demo','Demo.sln')

task :clean do
	sh "#{msbuild} /t:Clean /p:Configuration=Debug #{solution}"
end

task :build do
	sh "#{msbuild} /t:Build /p:Configuration=Debug #{solution}"
end

task :default => [:clean, :build]
