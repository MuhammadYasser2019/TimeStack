# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
#Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
#Rails.application.config.assets.precompile += %w( .svg .eot .woff .ttf )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(ckeditor/config.js)
Rails.application.config.assets.precompile += %w(orange.css)
Rails.application.config.assets.precompile += %w(blue.css)
Rails.application.config.assets.precompile += %w(cocoon.js)
Rails.application.config.assets.precompile += %w(ckeditor/*)
#Rails.application.config.assets.precompile += %w( *.js ^[^_]*.css *.scss *.coffee )
