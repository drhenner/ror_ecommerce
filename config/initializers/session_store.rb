require 'action_dispatch/middleware/session/dalli_store'
# Be sure to restart your server when you modify this file.

#Hadean::Application.config.session_store :cookie_store, :key => '_hadean_session'
#Hadean::Application.config.session_store ::Ripple::SessionStore
#Hadean::Application.config.session_store :mem_cache_store, :key => '_hadean_session'
Hadean::Application.config.session_store :dalli_store, :key => '_hadean_session_ugrdr6765745ce4vy'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Hadean::Application.config.session_store :active_record_store
