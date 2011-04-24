require 'sass/plugin/rack'
Sass::Plugin.options[:style] = :compact
Sass::Plugin.add_template_location(
    Rails.root.join('public', 'pwnstyles', 'stylesheets', 'scss').to_s,
    Rails.root.join('public', 'pwnstyles', 'stylesheets').to_s)

ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :pwnstyles =>
    [ '/pwnstyles/stylesheets/pwnstyles' ]
