Rails.application.config.dartsass.builds = {
  "application.scss"          => "application.css",
  "foundation_and_overrides.scss" => "foundation_and_overrides.css",
  "normalize.scss"            => "normalize.css",
  "sprite.scss"               => "sprite.css",
  "chosen.scss"               => "chosen.css",
  "markdown.scss"             => "markdown.css",
  "login.scss"                => "login.css",
  "signup.scss"               => "signup.css",
  "ie6.scss"                  => "ie6.css",
  "home_page.scss"            => "home_page.css",
  "product_page.scss"         => "product_page.css",
  "products_page.scss"        => "products_page.css",
  "pikachoose_product.scss"   => "pikachoose_product.css",
  "shopping_cart_page.scss"   => "shopping_cart_page.css",
  "tables.scss"               => "tables.css",
  "site/app.scss"             => "site/app.css",
  "admin/app.scss"            => "admin/app.css",
  "admin/cart.scss"           => "admin/cart.css",
  "admin/help.scss"           => "admin/help.css",
  "admin_new.scss"            => "admin_new.css"
}

Rails.application.config.dartsass.build_options = [
  "--load-path=vendor/assets/stylesheets/foundation",
  "--load-path=vendor/assets/stylesheets",
  "--load-path=app/assets/stylesheets",
  "--quiet-deps"
]
