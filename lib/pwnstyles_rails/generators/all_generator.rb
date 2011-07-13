require 'rails'

# :nodoc: namespace
module Pwnstyles

# rails g pwnstyles:all
class AllGenerator < Rails::Generators::Base
  source_root File.dirname(__FILE__)
  
  def copy_layout
    dir = File.expand_path 'layouts', File.dirname(__FILE__)
    Dir.glob(File.join(dir, '*'), File::FNM_DOTMATCH).each do |source|
      next if File.directory?(source)
      source_file = source[(dir.length + 1)..-1]
      dest = Rails.root.join 'app', 'views', 'layouts', source_file
      copy_file source, dest
    end
  end
  
  def copy_static_assets
    dir = File.expand_path 'assets',
                           File.dirname(__FILE__)
    Dir.glob(File.join(dir, '**', '*'), File::FNM_DOTMATCH).each do |source|
      next if File.directory?(source)
      source_file = source[(dir.length + 1)..-1]
      
      dest = Rails.root.join 'app', 'assets', source_file
      copy_file source, dest
    end
  end
end  # class Pwnstyles::AllGenerator

end  # namespace Pwnstyles
