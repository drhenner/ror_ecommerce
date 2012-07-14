module Hadean
  module I18n
    def self.included(base)
      base.extend Hadean::I18n
    end
    
    def set_locale
      if defined?(params) && params[:locale]
        ::I18n.locale = params[:locale]
      elsif defined?(request)
        ::I18n.locale = extract_locale_from_accept_language_header
      end
      ::I18n.locale ||= ::I18n.default_locale
    end

    def set_locale_for_lang(lang)
      ::I18n.locale = lang
    end
    
    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first) || "en"
    end

    def current_language
      ::I18n.locale
    end
    
    def valid_languages
      @@valid_languages ||= Dir.glob(File.join(Rails.root, 'config', 'locales', '*.yml')).collect {|f| File.basename(f).split('.').first}.collect(&:to_sym)
    end
    
  end
end
