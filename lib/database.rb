class DatabaseTask < Rake::TaskLib
	def initialize(params={})
		@env = params[:environment] || ENVIRONMENT
		
		yield self if block_given?
		define
	end

	def define
		dbs = FileList.new("#{DB_DIR}/*")
		dbs.each do |db|
			name = Pathname.new(db).basename
			cfg = YamlConfig.new("#{db}/#{name}.#{@env}.yml")

			desc "create database: #{name}"
			task "db_create_#{name}".to_sym do |t|

			end
		end

	end
end