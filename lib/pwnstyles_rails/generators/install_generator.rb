require 'rails'

# :nodoc: namespace
module PwnstylesRails


# rails g pwnstyles_rails:install
class InstallGenerator < UpdateGenerator
  def stylesheets
    copy_stylesheets []
  end
end  # class PwnstylesRails::AllGenerator

end  # namespace PwnstylesRails
