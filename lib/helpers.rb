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
