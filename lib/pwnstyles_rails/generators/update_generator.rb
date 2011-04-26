require 'rails'

# :nodoc: namespace
module PwnstylesRails


# rails g pwnstyles_rails:update
class UpdateGenerator < Rails::Generators::Base
  def static_assets
    copy_static_assets ['scss/vars/_app.scss']
  end


  private
  
  def copy_static_assets(exclude_list = [])
    copy_dir 'public/stylesheets', 'public/pwnstyles/stylesheets'
    copy_dir 'public/javascripts', 'public/javascripts'
  end
  
  def copy_dir(source_dir, destination_dir, exclude_list = [])
    dir = File.expand_path File.join('../../..', source_dir),
                           File.dirname(__FILE__)
    Dir.glob(File.join(dir, '**', '*'), File::FNM_DOTMATCH).each do |source|
      next if File.directory?(source)
      source_file = source[(dir.length + 1)..-1]
      next if exclude_list.include?(source_file)
      
      dest = Rails.root.join destination_dir, source_file
      copy_file source, dest
    end
  end
end  # class PwnstylesRails::AllGenerator

end  # namespace PwnstylesRails
