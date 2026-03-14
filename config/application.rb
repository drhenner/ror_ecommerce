require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Hadean
  class Application < Rails::Application
    config.load_defaults 8.1

    # Legacy overrides (app was written for Rails 4/5)
    config.active_record.belongs_to_required_by_default = false
    config.action_controller.action_on_open_redirect = :log

    config.time_zone = 'Eastern Time (US & Canada)'
    config.encoding = "utf-8"

    config.generators do |g|
      g.test_framework  :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    config.filter_parameters += [:password,
                                  :password_confirmation,
                                  :number,
                                  :cc_number,
                                  :cc_type,
                                  :brand,
                                  :card_number,
                                  :verification_value]
  end
end
