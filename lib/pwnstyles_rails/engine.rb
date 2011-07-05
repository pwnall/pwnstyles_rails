require 'pwnstyles_rails'
require 'rails'
require 'sass-rails'

# :nodoc: namespace
module PwnstylesRails

class Engine < Rails::Engine
  generators do
    require 'pwnstyles_rails/generators/update_generator.rb'
    require 'pwnstyles_rails/generators/install_generator.rb'
  end
  
  initializer :pwnstyles_paths, :after => :setup_sass do |app|
    app.config.sass.load_paths <<
        File.expand_path('../../stylesheets', File.dirname(__FILE__))
  end
end  # class PwnstylesRails::Engine

end  # namespace PwnstylesRails
