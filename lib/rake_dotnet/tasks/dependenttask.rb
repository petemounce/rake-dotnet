module DependentTask
	attr_accessor :dependencies, :ci_dependencies, :main_task_name, :is_local_build

	def initialize(params={})
		raise(ArgumentError, 'must supply task name', caller) if @main_task_name.nil?
		@is_local_build = params[:build_number].nil? || params[:build_number] == 0
		@dependencies = params[:dependencies] || []
		if @dependencies.is_a?(String)
			@dependencies = @dependencies.split(',')
		end

		@ci_dependencies = params[:ci_dependencies] || []
		if @ci_dependencies.is_a?(String)
			@ci_dependencies = @ci_dependencies.split(',')
		end

		if @is_local_build
			task @main_task_name => @dependencies
		else
			task @main_task_name => @ci_dependencies
		end
	end
end
