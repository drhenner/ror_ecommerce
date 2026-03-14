# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
Hadean::Application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'MyNewRORecommerceApp')
