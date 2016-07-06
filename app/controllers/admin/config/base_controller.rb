class Admin::Config::BaseController < Admin::BaseController
  skip_before_action :verify_admin
  before_action :verify_super_admin  # ONLY SUPER ADMINS should see this
  layout 'admin'
end
