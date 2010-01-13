TOOLS_DIR = 'support'
DB_SERVER = '.'
DB_USER = 'sa'
DB_PASSWORD = 'youREALLYdontwanttousethispasswordassa!'
PRODUCT_NAME = 'Foo'

OUT_DIR = 'out'
PRODUCT_ROOT = '.'
Bin_out = File.join(OUT_DIR, 'bin')
CONFIGURATION = 'Debug'

def re(str)
	return str.gsub('/', '\/').gsub('.', '\.')
end
