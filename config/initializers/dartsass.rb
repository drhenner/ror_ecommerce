Rails.application.config.dartsass.builds = {
  "markdown.scss"             => "markdown.css",
  "admin/app.scss"            => "admin/app.css",
  "admin/cart.scss"           => "admin/cart.css",
  "admin/help.scss"           => "admin/help.css",
  "admin_new.scss"            => "admin_new.css"
}

Rails.application.config.dartsass.build_options = [
  "--load-path=vendor/assets/stylesheets",
  "--load-path=app/assets/stylesheets",
  "--quiet-deps"
]
