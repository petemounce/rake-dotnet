require 'rake'
require 'foo_task.rb'
require 'bar_task.rb'
require 'baz_task.rb'

FooTask.new

BarTask.new do |t|
	t.message = 'this is not the default value'
end

baz = BazTask.new
baz.message = 'not the droids you''re looking for'

task :default => [:foo]
