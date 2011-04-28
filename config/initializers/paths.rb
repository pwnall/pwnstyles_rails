require 'sass/plugin/rack'
Sass::Plugin.add_template_location(
    Rails.root.join('public', 'pwnstyles', 'stylesheets', 'scss').to_s,
    Rails.root.join('public', 'pwnstyles', 'stylesheets').to_s)
Sass::Plugin.add_template_location(
    Rails.root.join('public', 'stylesheets', 'scss').to_s,
    Rails.root.join('public', 'stylesheets').to_s)

Sass::Plugin.options[:style] = Rails.env.development? ? :expanded : :compressed
Sass::Plugin.options[:debug] = Rails.env.development?

ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :pwnstyles =>
    [ '/pwnstyles/stylesheets/pwnstyles' ]
