require 'sass_embedded_sprockets'

Rails.application.config.assets.configure do |env|
  env.register_transformer 'text/sass', 'text/css', SassEmbeddedSprockets::SassProcessor
  env.register_transformer 'text/scss', 'text/css', SassEmbeddedSprockets::ScssProcessor
end

Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets', 'foundation').to_s
