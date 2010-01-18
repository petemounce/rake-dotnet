TOOLS_DIR = 'RakeDotNet/3rdparty'
DB_SERVER = '.'
DB_USER = 'sa'
DB_PASSWORD = 'youREALLYdontwanttousethispasswordassa!'
PRODUCT_NAME = 'Foo'

OUT_DIR = 'out'
PRODUCT_ROOT = 'RakeDotNet'
Bin_out = File.join(OUT_DIR, 'bin')
CONFIGURATION = 'Debug'

def re(str)
	return str.gsub('/', '\/').gsub('.', '\.')
end
