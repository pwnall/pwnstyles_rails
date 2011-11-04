require 'pwnstyles_rails'
require 'rails'
require 'sass-rails'

# :nodoc: namespace
module PwnstylesRails

class Engine < Rails::Engine
  engine_name 'pwnstyles'
  
  generators do
    require 'pwnstyles_rails/generators/all_generator.rb'
  end
end  # class PwnstylesRails::Engine

end  # namespace PwnstylesRails
