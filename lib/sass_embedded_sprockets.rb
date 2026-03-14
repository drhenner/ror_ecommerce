require 'sass-embedded'
require 'sprockets'
require 'uri'

module SassEmbeddedSprockets
  class ScssProcessor
    def self.syntax
      :scss
    end

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def self.cache_key
      instance.cache_key
    end

    attr_reader :cache_key

    def initialize
      @cache_key = "#{self.class.name}:#{Sass::Embedded::VERSION}".freeze
    end

    def call(input)
      context = input[:environment].context_class.new(input)
      load_paths = input[:environment].paths.dup

      sass_config = Rails.application.config.sass if Rails.application.config.respond_to?(:sass)
      if sass_config&.respond_to?(:load_paths) && sass_config.load_paths
        load_paths += sass_config.load_paths
      end

      result = Sass.compile_string(
        input[:data],
        syntax: self.class.syntax,
        url: pathToFileUrl(input[:filename]),
        load_paths: load_paths,
        style: :expanded,
        quiet_deps: true,
        fatal_deprecations: [],
        silence_deprecations: ['import', 'slash-div', 'color-functions', 'global-builtin'],
        logger: Sass::Logger.silent,
        functions: build_functions(context)
      )

      result.loaded_urls.each do |url|
        next unless url.start_with?('file:')
        dep_path = file_url_to_path(url)
        next if dep_path == input[:filename]
        context.metadata[:dependencies] << Sprockets::URIUtils.build_file_digest_uri(dep_path)
      end

      context.metadata.merge(data: result.css)
    end

    private

    def pathToFileUrl(path)
      "file://#{URI::DEFAULT_PARSER.escape(path)}"
    end

    def file_url_to_path(url)
      URI::DEFAULT_PARSER.unescape(url.sub(%r{^file://}, ''))
    end

    def build_functions(context)
      {
        'image-url($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path, type: :image)
          Sass::Value::String.new("url(#{resolved})", quoted: false)
        },
        'image-path($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path, type: :image)
          Sass::Value::String.new(resolved)
        },
        'font-url($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path, type: :font)
          Sass::Value::String.new("url(#{resolved})", quoted: false)
        },
        'font-path($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path, type: :font)
          Sass::Value::String.new(resolved)
        },
        'asset-url($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path)
          Sass::Value::String.new("url(#{resolved})", quoted: false)
        },
        'asset-path($path)' => ->(args) {
          path = args[0].assert_string('path').text
          resolved = context.asset_path(path)
          Sass::Value::String.new(resolved)
        },
        'asset-data-url($path)' => ->(args) {
          path = args[0].assert_string('path').text
          url = context.asset_data_uri(path)
          Sass::Value::String.new("url(#{url})", quoted: false)
        }
      }
    end
  end

  class SassProcessor < ScssProcessor
    def self.syntax
      :indented
    end
  end
end
