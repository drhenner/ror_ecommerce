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
  end
end
