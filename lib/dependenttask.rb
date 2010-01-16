module DependentTask
	attr_accessor :dependencies
	
	def initialize(params={})
		raise(ArgumentError, 'must supply task name', caller) if @main_task_name.nil?
		@dependencies = params[:dependencies] || []
		if @dependencies.is_a?(String)
			@dependencies = @dependencies.join(',')
		end
		@is_local_build = params[:build_number].nil? || params[:build_number] == 0

		if (@is_local_build)
			task @main_task_name => @dependencies
		end
	end
end
