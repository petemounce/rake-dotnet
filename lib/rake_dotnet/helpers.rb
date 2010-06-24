def regexify(path)
	return path.gsub('/', '\/').gsub('.', '\.')
end

def to_attr(input)
	return input.to_s.gsub(' ', '| ').gsub('"', '|"').gsub('\\', '|\\').gsub('#', '|#').gsub('\'', '|\'').gsub('.', '|.')
end
