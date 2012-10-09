require 'openssl'

module EncryptionHelper

  #### NOTE #### APP_CONFIG[:encryption_key] from config/config.yml
  #   should be stored on the server and not in your applications code base
  module AES256CBC
    def encrypt(plaintext)
      aes = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
      aes.encrypt # must be call before #key and #iv
      aes.key = Settings.encryption_key
      aes.iv = iv = aes.random_iv
      ciphertext = aes.update(plaintext)
      ciphertext <<  aes.final
      return iv, ciphertext
    end

    def decrypt(iv, ciphertext)
      aes = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
      aes.decrypt # must be called before aes.key aes.iv
      aes.key = Settings.encryption_key
      aes.iv = iv
      plaintext = aes.update(ciphertext)
      plaintext << aes.final
    end
  end

end
