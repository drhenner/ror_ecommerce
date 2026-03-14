Rails.application.config.after_initialize do
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
    !  You need to setup the settings.yml
    !  copy settings.yml.example to settings.yml
    !
    !  YOUR ENV variables are not ready for checkout!
    !  please adjust ENV['AUTHNET_LOGIN'] && ENV['AUTHNET_PASSWORD']
    ############################################################################################
    "
  end
end
