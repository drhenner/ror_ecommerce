module Hadean
  module TruncateHelper

    UNSEEDED_TABLES = [ 'addresses',
                        'batches',
                        'brands',
                        'carts',
                        'cart_items',
                        'comments',
                        'coupons',
                        'deals',
                        'images',
                        'image_groups',
                        'inventories',
                        'invoices',
                        'newsletters',
                        'orders',
                        'order_items',
                        'payments',
                        'payment_profiles',
                        'phones',
                        'products',
                        'product_properties',
                        'product_types',
                        'prototypes',
                        'prototype_properties',
                        'purchase_orders',
                        'purchase_order_variants',
                        'return_authorizations',
                        'return_items',
                        'referrals',
                        'sales',
                        'shipments',
                        'shipping_categories',
                        'shipping_methods',
                        'shipping_rates',
                        'suppliers',
                        'tax_rates',
                        'transactions',
                        'transaction_ledgers',
                        "users",
                        "user_roles",
                        'variants',
                        'variant_properties',
                        'variant_suppliers'
                      ]

    def truncate_all
      tables = ActiveRecord::Base.connection.tables
      tables.each { |table| truncate table }
    end


    def trunctate_unseeded
      UNSEEDED_TABLES.each { |table| truncate table }
    end

    def truncate table
      config = ActiveRecord::Base.configurations[Rails.env]

      if config['adapter'] == 'sqlite3'
        ActiveRecord::Base.connection.execute "DELETE FROM #{table}"
      else
        ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table}"
      end
    end
  end
end
