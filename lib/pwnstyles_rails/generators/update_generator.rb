require 'rails'

# :nodoc: namespace
module PwnstylesRails


# rails g pwnstyles_rails:update
class UpdateGenerator < Rails::Generators::Base
  def stylesheets
    copy_stylesheets ['scss/vars/_app.scss']
  end


  private
  
  def copy_stylesheets(exclude_list = [])
    dir = File.expand_path '../../../public/stylesheets', File.dirname(__FILE__)
    Dir.glob(File.join(dir, '**', '*'), File::FNM_DOTMATCH).each do |source|
      next if File.directory?(source)
      source_file = source[(dir.length + 1)..-1]
      next if exclude_list.include?(source_file)
      
      dest = Rails.root.join 'public', 'pwnstyles', 'stylesheets', source_file
      copy_file source, dest
    end
  end
end  # class PwnstylesRails::AllGenerator

end  # namespace PwnstylesRails
