def regexify(path)
	return path.gsub('/', '\/').gsub('.', '\.')
end

def to_attr(input)
	return input.gsub(' ', '| ').gsub('"', '|"').gsub('\\','|\\').gsub('#','|#').gsub('\'', '|\'').gsub('.','|.')
end
