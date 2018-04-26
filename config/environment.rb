# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../../lib/printing/invoice_printer', __FILE__)

# Initialize the rails application
Hadean::Application.initialize!
Hadean::Application.configure do
  config.after_initialize do
    unless Settings.encryption_key
      raise "
      ############################################################################################
      !  You need to setup the settings.yml
      !  copy settings.yml.example to settings.yml
      !
      !  Make sure you personalize the passwords in this file and for security never check this file in.
      ############################################################################################
      "
    end
    unless Settings.authnet.login
      puts "
      ############################################################################################
      ############################################################################################
      !  You need to setup the settings.yml
      !  copy settings.yml.example to settings.yml
      !
      !  YOUR ENV variables are not ready for checkout!
      !  please adjust ENV['AUTHNET_LOGIN'] && ENV['AUTHNET_PASSWORD']
      !  if you are not using authorize.net go to each file in /config/environments/*.rb and
      !  adjust the following code accordingly...

      ::GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
        :login    => Settings.authnet.login,
        :password => Settings.authnet.password
      )

      !  This is required for the checkout process to work.
      !
      !  Remove or Adjust this warning in /config/environment.rb for developers on your team
      !  once you have everything working with your specific Gateway.
      ############################################################################################
      "
    end
  end
end
