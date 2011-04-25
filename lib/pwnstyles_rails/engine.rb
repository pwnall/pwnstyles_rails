require 'pwnstyles_rails'
require 'rails'

# :nodoc: namespace
module PwnstylesRails

class Engine < Rails::Engine
  generators do
    require 'pwnstyles_rails/generators/update_generator.rb'
    require 'pwnstyles_rails/generators/install_generator.rb'
  end
end  # class PwnstylesRails::Engine

end  # namespace PwnstylesRails
