require 'rails'

# :nodoc: namespace
module Pwnstyles


# rails g pwnstyles:install
class InstallGenerator < UpdateGenerator
  def staic_assets
    copy_static_assets []
  end
  
  def layout
    dir = File.expand_path 'layouts', File.dirname(__FILE__)
    Dir.glob(File.join(dir, '*'), File::FNM_DOTMATCH).each do |source|
      next if File.directory?(source)
      source_file = source[(dir.length + 1)..-1]
      dest = Rails.root.join 'app', 'views', 'layouts', source_file
      copy_file source, dest
    end
  end
end  # class Pwnstyles::AllGenerator

end  # namespace Pwnstyles
