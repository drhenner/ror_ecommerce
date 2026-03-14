# This app was originally written for Rails 4/5 where belongs_to was optional.
# Disable the Rails 5+ default that requires belongs_to associations to be present.
Rails.application.config.active_record.belongs_to_required_by_default = false

# The app has redirect URLs that may be user-influenced; keep the legacy
# permissive behavior until all redirects are audited.
Rails.application.config.action_controller.raise_on_open_redirects = false
