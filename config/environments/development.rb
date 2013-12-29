Hadean::Application.configure do
  # Rails 4
  config.eager_load = false

  # Settings specified here will take precedence over those in config/environment.rb

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.cache_store = :memory_store

  #config.cache_store = :dalli_store
  #config.cache_store = :redis_store
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }


  config.after_initialize do
    #Formtastic::SemanticFormBuilder.send(:include, Formtastic::DatePicker)
    #Formtastic::SemanticFormBuilder.send(:include, Formtastic::FuturePicker)
    #Formtastic::SemanticFormBuilder.send(:include, Formtastic::YearPicker)

    ActiveMerchant::Billing::Base.mode = :test
    #::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
    #  :login      => Settings.paypal.login,
    #  :password   => Settings.paypal.password,
    #  :signature  => Settings.paypal.signature
    #)

    ::GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
      :login    => Settings.authnet.login,
      :password => Settings.authnet.password,
      :test     => true   #  Make sure this is pointing to the authnet test server.  This needs to be uncommented to test capturing a payment.
    )
#
#    ::CIM_GATEWAY = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
#      :login    => Settings.authnet.login,
#      :password => Settings.authnet.password,
#      :test     => true   #  Make sure this is pointing to the authnet test server.  This needs to be uncommented to test capturing a payment.
#    )
    #::GATEWAY = ActiveMerchant::Billing::BraintreeGateway.new(
    #  :login     => Settings.braintree.login,
    #  :password  => Settings.braintree.password
    #)
  end

  PAPERCLIP_STORAGE_OPTS = {  :styles => {:mini => '48x48>',
                                          :small    => '100x100>',
                                          :medium   => '200x200>',
                                          :product  => '320x320>',
                                          :large    => '600x600>' },
                              :default_style => :product,
                              :url => "/assets/products/:id/:style/:basename.:extension",
                              :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension" }
end
