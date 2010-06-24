class NDependConsoleCmd < Cli
	attr_accessor :project, :out_dir, :should_publish

	def initialize(params={})
		sps = params[:search_paths] || []
		sps << File.join(TOOLS_DIR, 'ndepend')
		super(params.merge(:exe_name=>'ndepend.console.exe', :search_paths=>sps))

		@project = params[:project] || PRODUCT_NAME + '.ndepend.xml'
		@out_dir = params[:out_dir] || File.join(OUT_DIR, 'reports', 'ndepend')
		@should_publish = params[:should_publish] || !ENV['BUILD_NUMBER'].nil? || false
	end

	def out_dir
		od = File.expand_path(@out_dir).gsub('/', '\\')
		return "/OutDir \"#{od}\""
	end

	def project
		p = File.expand_path(@project).gsub('/', '\\')
		return "\"#{p}\""
	end

	def cmd
		return "#{super} #{project} #{out_dir}"
	end

	def run
		puts cmd if verbose
		sh cmd
		publish if @should_publish
	end

	def publish
		ndepend_doc = REXML::Document.new(File.open("#{@out_dir}/CQLResult.xml"))
		stats_data = {}
		stats_data['NDependCQLTotal'] = 0
		ndepend_doc.elements.each('CQLResult/Group') do |group|
			specific = "NDepend_Warn_#{group.attributes['Name']}"
			group.elements.each('Query') do |query|
				stats_data['NDependCQLTotal'] += query.attributes['NbNodeMatched'].to_i
				specific_query = to_attr("#{specific}_#{query.attributes['Name']}")
				stats_data[specific_query] = query.attributes['NbNodeMatched'].to_i
			end
		end

		stats_data.sort.each do |key, value|
			puts "##teamcity[buildStatisticValue key='#{key}' value='#{value}']"
		end
	end
end
