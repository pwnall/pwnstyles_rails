require 'rails'

# :nodoc: namespace
module PwnstylesRails


# Name chosen to get configvars_rails:all
class AllGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def copy_stylesheets
    dir = File.expand_path '../../public/stylesheets', File.dirname(__FILE__)
    Dir.glob(File.join(dir, '**', '*')).each do |source|
      next if File.directory?(source)
      dest = Rails.root.join 'public', 'pwnstyles', 'stylesheets',
                             source[(dir.length + 1)..-1]
      copy_file source, dest
    end
  end
end  # class PwnstylesRails::AllGenerator

end  # namespace PwnstylesRails
