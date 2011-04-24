require 'pwnstyles_rails'
require 'rails'

# :nodoc: namespace
module AuthpwnRails

class Engine < Rails::Engine
  generators do
    require 'pwnstyles_rails/all_generator.rb'
  end
end  # class AuthpwnRails::Engine

end  # namespace AuthpwnRails
