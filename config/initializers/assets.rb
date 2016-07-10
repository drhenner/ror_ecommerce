# Precompile additional assets
Rails.application.config.assets.precompile += %w( .svg .eot .woff .ttf )
Rails.application.config.assets.precompile += %w( *.js )
Rails.application.config.assets.precompile += [ 'admin.css',
                                                'admin/app.css',
                                                'admin/cart.css',
                                                'admin/foundation.css',
                                                'admin/normalize.css',
                                                'admin/help.css',
                                                'admin/ie.css',
                                                'autocomplete.css',
                                                'application.css',
                                                'chosen.css',
                                                'foundation.css',
                                                'foundation_and_overrides.css',
                                                'home_page.css',
                                                'ie.css',
                                                'ie6.css',
                                                'login.css',
                                                'markdown.css',
                                                'markitup/skins/markitup/style.css',
                                                'markitup/sets/default/style.css',
                                                'myaccount.css',
                                                'normalize.css',
                                                'pikachoose_product.css',
                                                'product_page.css',
                                                'products_page.css',
                                                'shopping_cart_page.css',
                                                'signup.css',
                                                'site/app.css',
                                                'sprite.css',
                                                'tables.css',
                                                'cupertino/jquery-ui-1.8.12.custom.css',# in vendor
                                                'modstyles.css', # in vendor
                                                'scaffold.css', # in vendor
                                                'vendor/modernizr.js'
                                                ]
