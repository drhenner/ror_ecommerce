# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160813202558) do

  create_table "accounting_adjustments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "adjustable_id", null: false
    t.string "adjustable_type", null: false
    t.string "notes"
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["adjustable_id"], name: "index_accounting_adjustments_on_adjustable_id"
  end

  create_table "accounts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "account_type", null: false
    t.decimal "monthly_charge", precision: 8, scale: 2, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "address_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 64, null: false
    t.string "description"
    t.index ["name"], name: "index_address_types_on_name"
  end

  create_table "addresses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "address_type_id"
    t.string "first_name"
    t.string "last_name"
    t.string "addressable_type", null: false
    t.integer "addressable_id", null: false
    t.string "address1", null: false
    t.string "address2"
    t.string "city", null: false
    t.integer "state_id"
    t.string "state_name"
    t.string "zip_code", null: false
    t.integer "phone_id"
    t.string "alternative_phone"
    t.boolean "default", default: false
    t.boolean "billing_default", default: false
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "country_id"
    t.index ["addressable_id"], name: "index_addresses_on_addressable_id"
    t.index ["addressable_type"], name: "index_addresses_on_addressable_type"
    t.index ["state_id"], name: "index_addresses_on_state_id"
  end

  create_table "batches", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "batchable_type"
    t.integer "batchable_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["batchable_id"], name: "index_batches_on_batchable_id"
    t.index ["batchable_type"], name: "index_batches_on_batchable_type"
  end

  create_table "brands", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "cart_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "cart_id"
    t.integer "variant_id", null: false
    t.integer "quantity", default: 1
    t.boolean "active", default: true
    t.integer "item_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["item_type_id"], name: "index_cart_items_on_item_type_id"
    t.index ["user_id"], name: "index_cart_items_on_user_id"
    t.index ["variant_id"], name: "index_cart_items_on_variant_id"
  end

  create_table "carts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "customer_id"
    t.index ["customer_id"], name: "index_carts_on_customer_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "note"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.integer "created_by"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["created_by"], name: "index_comments_on_created_by"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "countries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "abbreviation", limit: 5
    t.integer "shipping_zone_id"
    t.boolean "active", default: false
    t.index ["active"], name: "index_countries_on_active"
    t.index ["name"], name: "index_countries_on_name"
    t.index ["shipping_zone_id", "active"], name: "index_countries_on_shipping_zone_id_and_active"
  end

  create_table "coupons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type", null: false
    t.string "code", null: false
    t.decimal "amount", precision: 8, scale: 2, default: "0.0"
    t.decimal "minimum_value", precision: 8, scale: 2
    t.integer "percent", default: 0
    t.text "description", null: false
    t.boolean "combine", default: false
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_coupons_on_code"
    t.index ["expires_at"], name: "index_coupons_on_expires_at"
  end

  create_table "deal_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "buy_quantity", null: false
    t.integer "get_percentage"
    t.integer "deal_type_id", null: false
    t.integer "product_type_id", null: false
    t.integer "get_amount"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["buy_quantity"], name: "index_deals_on_buy_quantity"
    t.index ["deal_type_id"], name: "index_deals_on_deal_type_id"
    t.index ["product_type_id"], name: "index_deals_on_product_type_id"
  end

  create_table "image_groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.integer "product_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_image_groups_on_product_id"
  end

  create_table "images", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "imageable_id"
    t.string "imageable_type"
    t.integer "image_height"
    t.integer "image_width"
    t.integer "position"
    t.string "caption"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.index ["imageable_id"], name: "index_images_on_imageable_id"
    t.index ["imageable_type"], name: "index_images_on_imageable_type"
    t.index ["position"], name: "index_images_on_position"
  end

  create_table "inventories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "count_on_hand", default: 0
    t.integer "count_pending_to_customer", default: 0
    t.integer "count_pending_from_supplier", default: 0
  end

  create_table "invoices", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.string "invoice_type", default: "Purchase", null: false
    t.string "state", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "credited_amount", precision: 8, scale: 2, default: "0.0"
    t.index ["order_id"], name: "index_invoices_on_order_id"
  end

  create_table "item_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
  end

  create_table "newsletters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.boolean "autosubscribe", null: false
  end

  create_table "notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.string "type", null: false
    t.integer "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "send_at"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["type", "user_id"], name: "index_notifications_on_type_and_user_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal "price", precision: 8, scale: 2
    t.decimal "total", precision: 8, scale: 2
    t.integer "order_id", null: false
    t.integer "variant_id", null: false
    t.string "state", null: false
    t.integer "tax_rate_id"
    t.integer "shipping_rate_id"
    t.integer "shipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["shipment_id"], name: "index_order_items_on_shipment_id"
    t.index ["shipping_rate_id"], name: "index_order_items_on_shipping_rate_id"
    t.index ["tax_rate_id"], name: "index_order_items_on_tax_rate_id"
    t.index ["variant_id"], name: "index_order_items_on_variant_id"
  end

  create_table "orders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "number"
    t.string "ip_address"
    t.string "email"
    t.string "state"
    t.integer "user_id"
    t.integer "bill_address_id"
    t.integer "ship_address_id"
    t.integer "coupon_id"
    t.boolean "active", default: true, null: false
    t.boolean "shipped", default: false, null: false
    t.integer "shipments_count", default: 0
    t.datetime "calculated_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "credited_amount", precision: 8, scale: 2, default: "0.0"
    t.index ["bill_address_id"], name: "index_orders_on_bill_address_id"
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["email"], name: "index_orders_on_email"
    t.index ["number"], name: "index_orders_on_number"
    t.index ["ship_address_id"], name: "index_orders_on_ship_address_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_profiles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "address_id"
    t.string "payment_cim_id"
    t.boolean "default"
    t.boolean "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "last_digits"
    t.string "month"
    t.string "year"
    t.string "cc_type"
    t.string "first_name"
    t.string "last_name"
    t.string "card_name"
    t.index ["address_id"], name: "index_payment_profiles_on_address_id"
    t.index ["user_id"], name: "index_payment_profiles_on_user_id"
  end

  create_table "payments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "invoice_id"
    t.string "confirmation_id"
    t.integer "amount"
    t.string "error"
    t.string "error_code"
    t.string "message"
    t.string "action"
    t.text "params"
    t.boolean "success"
    t.boolean "test"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "phone_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "phones", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "phone_type_id"
    t.string "number", null: false
    t.string "phoneable_type", null: false
    t.integer "phoneable_id", null: false
    t.boolean "primary", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["phone_type_id"], name: "index_phones_on_phone_type_id"
    t.index ["phoneable_id"], name: "index_phones_on_phoneable_id"
    t.index ["phoneable_type"], name: "index_phones_on_phoneable_type"
  end

  create_table "product_properties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "product_id", null: false
    t.integer "property_id", null: false
    t.integer "position"
    t.string "description", null: false
    t.index ["product_id"], name: "index_product_properties_on_product_id"
    t.index ["property_id"], name: "index_product_properties_on_property_id"
  end

  create_table "product_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.boolean "active", default: true
    t.integer "rgt"
    t.integer "lft"
    t.index ["lft"], name: "index_product_types_on_lft"
    t.index ["parent_id"], name: "index_product_types_on_parent_id"
    t.index ["rgt"], name: "index_product_types_on_rgt"
  end

  create_table "products", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.text "description"
    t.text "product_keywords"
    t.integer "product_type_id", null: false
    t.integer "prototype_id"
    t.integer "shipping_category_id", null: false
    t.string "permalink", null: false
    t.datetime "available_at"
    t.datetime "deleted_at"
    t.string "meta_keywords"
    t.string "meta_description"
    t.boolean "featured", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description_markup"
    t.integer "brand_id"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
    t.index ["name"], name: "index_products_on_name"
    t.index ["permalink"], name: "index_products_on_permalink", unique: true
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
    t.index ["prototype_id"], name: "index_products_on_prototype_id"
    t.index ["shipping_category_id"], name: "index_products_on_shipping_category_id"
  end

  create_table "properties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "identifing_name", null: false
    t.string "display_name"
    t.boolean "active", default: true
  end

  create_table "prototype_properties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "prototype_id", null: false
    t.integer "property_id", null: false
    t.index ["property_id"], name: "index_prototype_properties_on_property_id"
    t.index ["prototype_id"], name: "index_prototype_properties_on_prototype_id"
  end

  create_table "prototypes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
  end

  create_table "purchase_order_variants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "purchase_order_id", null: false
    t.integer "variant_id", null: false
    t.integer "quantity", null: false
    t.decimal "cost", precision: 8, scale: 2, null: false
    t.boolean "is_received", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["purchase_order_id"], name: "index_purchase_order_variants_on_purchase_order_id"
    t.index ["variant_id"], name: "index_purchase_order_variants_on_variant_id"
  end

  create_table "purchase_orders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "supplier_id", null: false
    t.string "invoice_number"
    t.string "tracking_number"
    t.string "notes"
    t.string "state"
    t.datetime "ordered_at", null: false
    t.date "estimated_arrival_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "total_cost", precision: 8, scale: 2, default: "0.0", null: false
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["tracking_number"], name: "index_purchase_orders_on_tracking_number"
  end

  create_table "referral_bonuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "amount", null: false
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_programs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "active", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "referral_bonus_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["referral_bonus_id"], name: "index_referral_programs_on_referral_bonus_id"
  end

  create_table "referral_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "referrals", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "applied", default: false
    t.datetime "clicked_at"
    t.string "email", null: false
    t.string "name"
    t.datetime "purchased_at"
    t.integer "referral_program_id", null: false
    t.integer "referral_type_id", null: false
    t.integer "referral_user_id"
    t.integer "referring_user_id", null: false
    t.datetime "registered_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_referrals_on_email", length: { email: 6 }
    t.index ["referral_program_id"], name: "index_referrals_on_referral_program_id"
    t.index ["referral_type_id"], name: "index_referrals_on_referral_type_id"
    t.index ["referral_user_id"], name: "index_referrals_on_referral_user_id"
    t.index ["referring_user_id"], name: "index_referrals_on_referring_user_id"
  end

  create_table "return_authorizations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "number"
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.decimal "restocking_fee", precision: 8, scale: 2, default: "0.0"
    t.integer "order_id", null: false
    t.integer "user_id", null: false
    t.string "state", null: false
    t.integer "created_by"
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_by"], name: "index_return_authorizations_on_created_by"
    t.index ["number"], name: "index_return_authorizations_on_number"
    t.index ["order_id"], name: "index_return_authorizations_on_order_id"
    t.index ["user_id"], name: "index_return_authorizations_on_user_id"
  end

  create_table "return_conditions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "label"
    t.string "description"
  end

  create_table "return_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "return_authorization_id", null: false
    t.integer "order_item_id", null: false
    t.integer "return_condition_id"
    t.integer "return_reason_id"
    t.boolean "returned", default: false
    t.integer "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["order_item_id"], name: "index_return_items_on_order_item_id"
    t.index ["return_authorization_id"], name: "index_return_items_on_return_authorization_id"
    t.index ["return_condition_id"], name: "index_return_items_on_return_condition_id"
    t.index ["return_reason_id"], name: "index_return_items_on_return_reason_id"
    t.index ["updated_by"], name: "index_return_items_on_updated_by"
  end

  create_table "return_reasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "label"
    t.string "description"
  end

  create_table "roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", limit: 30, null: false
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "sales", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "product_id"
    t.decimal "percent_off", precision: 8, scale: 2, default: "0.0"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["product_id"], name: "index_sales_on_product_id"
  end

  create_table "shipments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id"
    t.integer "shipping_method_id", null: false
    t.integer "address_id", null: false
    t.string "tracking"
    t.string "number", null: false
    t.string "state", null: false
    t.datetime "shipped_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["address_id"], name: "index_shipments_on_address_id"
    t.index ["number"], name: "index_shipments_on_number"
    t.index ["order_id"], name: "index_shipments_on_order_id"
    t.index ["shipping_method_id"], name: "index_shipments_on_shipping_method_id"
  end

  create_table "shipping_categories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "shipping_methods", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.integer "shipping_zone_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["shipping_zone_id"], name: "index_shipping_methods_on_shipping_zone_id"
  end

  create_table "shipping_rate_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "shipping_rates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "shipping_method_id", null: false
    t.decimal "rate", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "shipping_rate_type_id", null: false
    t.integer "shipping_category_id", null: false
    t.decimal "minimum_charge", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "position"
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["shipping_category_id"], name: "index_shipping_rates_on_shipping_category_id"
    t.index ["shipping_method_id"], name: "index_shipping_rates_on_shipping_method_id"
    t.index ["shipping_rate_type_id"], name: "index_shipping_rates_on_shipping_rate_type_id"
  end

  create_table "shipping_zones", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "slugs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "sluggable_id"
    t.integer "sequence", default: 1, null: false
    t.string "sluggable_type", limit: 40
    t.string "scope"
    t.datetime "created_at"
    t.index ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true
    t.index ["sluggable_id"], name: "index_slugs_on_sluggable_id"
  end

  create_table "states", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "abbreviation", limit: 5, null: false
    t.string "described_as"
    t.integer "country_id", null: false
    t.integer "shipping_zone_id", null: false
    t.index ["abbreviation"], name: "index_states_on_abbreviation"
    t.index ["country_id"], name: "index_states_on_country_id"
    t.index ["name"], name: "index_states_on_name"
  end

  create_table "store_credits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal "amount", precision: 8, scale: 2, default: "0.0"
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_store_credits_on_user_id"
  end

  create_table "suppliers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_rates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.decimal "percentage", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "state_id"
    t.integer "country_id"
    t.date "start_date", null: false
    t.date "end_date"
    t.boolean "active", default: true
    t.index ["state_id"], name: "index_tax_rates_on_state_id"
  end

  create_table "tax_statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "transaction_accounts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_ledgers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "accountable_type"
    t.integer "accountable_id"
    t.integer "transaction_id"
    t.integer "transaction_account_id"
    t.decimal "tax_amount", precision: 8, scale: 2, default: "0.0"
    t.decimal "debit", precision: 8, scale: 2, null: false
    t.decimal "credit", precision: 8, scale: 2, null: false
    t.string "period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["accountable_id"], name: "index_transaction_ledgers_on_accountable_id"
    t.index ["transaction_account_id"], name: "index_transaction_ledgers_on_transaction_account_id"
    t.index ["transaction_id"], name: "index_transaction_ledgers_on_transaction_id"
  end

  create_table "transactions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type"
    t.integer "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["batch_id"], name: "index_transactions_on_batch_id"
  end

  create_table "user_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "state"
    t.integer "account_id"
    t.string "customer_cim_id"
    t.string "password_salt"
    t.string "crypted_password"
    t.string "perishable_token"
    t.string "persistence_token"
    t.string "access_token"
    t.integer "comments_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["access_token"], name: "index_users_on_access_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["perishable_token"], name: "index_users_on_perishable_token", unique: true
    t.index ["persistence_token"], name: "index_users_on_persistence_token", unique: true
  end

  create_table "users_newsletters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "newsletter_id"
    t.datetime "updated_at", null: false
    t.index ["newsletter_id"], name: "index_users_newsletters_on_newsletter_id"
    t.index ["user_id"], name: "index_users_newsletters_on_user_id"
  end

  create_table "variant_properties", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "variant_id", null: false
    t.integer "property_id", null: false
    t.string "description", null: false
    t.boolean "primary", default: false
    t.index ["property_id"], name: "index_variant_properties_on_property_id"
    t.index ["variant_id"], name: "index_variant_properties_on_variant_id"
  end

  create_table "variant_suppliers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "variant_id", null: false
    t.integer "supplier_id", null: false
    t.decimal "cost", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "total_quantity_supplied", default: 0
    t.integer "min_quantity", default: 1
    t.integer "max_quantity", default: 10000
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["supplier_id"], name: "index_variant_suppliers_on_supplier_id"
    t.index ["variant_id"], name: "index_variant_suppliers_on_variant_id"
  end

  create_table "variants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "product_id", null: false
    t.string "sku", null: false
    t.string "name"
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "cost", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "deleted_at"
    t.boolean "master", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "inventory_id"
    t.integer "image_group_id"
    t.index ["inventory_id"], name: "index_variants_on_inventory_id"
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku"
  end

end
