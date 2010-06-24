require 'spec'

shared_examples_for 'A DependentTask' do
  it 'should have a dependencies accessor' do
    @task.should respond_to(:dependencies)
  end
  it 'should have a ci_dependencies accessor' do
    @task.should respond_to(:ci_dependencies)
  end
  it 'should make the main-task dependent on the dependencies passed when it is a local build' do
    @task.dependencies.each do |d|
      Rake::Task[@task.main_task_name].prerequisites.should include(d.to_s)
    end
  end
  it 'should make the main-task dependent on the ci_dependencies passed when it is not a local build' do
    @task.ci_dependencies.each do |d|
      @task.is_local_build = false
      Rake::Task[@task.main_task_name].prerequisites.should include(d.to_s)
    end
  end
end
