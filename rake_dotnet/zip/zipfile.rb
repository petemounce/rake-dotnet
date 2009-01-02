require 'zip/zip'
module Zip
  class ZipFile
    def add_dir(zip_path, src)
      self.mkdir(zip_path)
      Dir.foreach(src) do |fn|
        if fn[0] != '.'[0]
          current_file = src + '/' + fn
          current_file_zip_path = zip_path + '/' + fn
          if File.directory?(current_file)
            self.add_dir(current_file_zip_path, current_file)
          else
            self.add(current_file_zip_path, current_file)
          end
        end
      end
    end
  end
end
