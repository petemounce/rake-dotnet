root = Pathname.new(__FILE__).dirname

TOOLS_DIR = "#{root}/../RakeDotNet/3rdparty"
DB_SERVER = '.'
DB_USER = 'sa'
DB_PASSWORD = 'youREALLYdontwanttousethispasswordassa!'
PRODUCT_NAME = 'Foo'

OUT_DIR = "#{root}/../RakeDotNet/build/out"
PRODUCT_ROOT = "#{root}/../RakeDotNet"
Bin_out = File.join(OUT_DIR, 'bin')
CONFIGURATION = 'Debug'

def re(str)
  return str.gsub('/', '\\\/').gsub('.', '\\.')
end
