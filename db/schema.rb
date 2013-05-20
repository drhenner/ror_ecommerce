# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130415034400) do

  create_table "accounting_adjustments", force: true do |t|
    t.integer  "adjustable_id",                           null: false
    t.string   "adjustable_type",                         null: false
    t.string   "notes"
    t.decimal  "amount",          precision: 8, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounting_adjustments", ["adjustable_id"], name: "index_accounting_adjustments_on_adjustable_id", using: :btree

  create_table "accounts", force: true do |t|
    t.string   "name",                                                  null: false
    t.string   "account_type",                                          null: false
    t.decimal  "monthly_charge", precision: 8, scale: 2, default: 0.0,  null: false
    t.boolean  "active",                                 default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "address_types", force: true do |t|
    t.string "name",        limit: 64, null: false
    t.string "description"
  end

  add_index "address_types", ["name"], name: "index_address_types_on_name", using: :btree

  create_table "addresses", force: true do |t|
    t.integer  "address_type_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "addressable_type",                  null: false
    t.integer  "addressable_id",                    null: false
    t.string   "address1",                          null: false
    t.string   "address2"
    t.string   "city",                              null: false
    t.integer  "state_id"
    t.string   "state_name"
    t.string   "zip_code",                          null: false
    t.integer  "phone_id"
    t.string   "alternative_phone"
    t.boolean  "default",           default: false
    t.boolean  "billing_default",   default: false
    t.boolean  "active",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
  end

  add_index "addresses", ["addressable_id"], name: "index_addresses_on_addressable_id", using: :btree
  add_index "addresses", ["addressable_type"], name: "index_addresses_on_addressable_type", using: :btree
  add_index "addresses", ["state_id"], name: "index_addresses_on_state_id", using: :btree

  create_table "batches", force: true do |t|
    t.string   "batchable_type"
    t.integer  "batchable_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batches", ["batchable_id"], name: "index_batches_on_batchable_id", using: :btree
  add_index "batches", ["batchable_type"], name: "index_batches_on_batchable_type", using: :btree

  create_table "brands", force: true do |t|
    t.string "name"
  end

  create_table "cart_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "cart_id"
    t.integer  "variant_id",                  null: false
    t.integer  "quantity",     default: 1
    t.boolean  "active",       default: true
    t.integer  "item_type_id",                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["item_type_id"], name: "index_cart_items_on_item_type_id", using: :btree
  add_index "cart_items", ["user_id"], name: "index_cart_items_on_user_id", using: :btree
  add_index "cart_items", ["variant_id"], name: "index_cart_items_on_variant_id", using: :btree

  create_table "carts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "carts", ["customer_id"], name: "index_carts_on_customer_id", using: :btree
  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "note"
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.integer  "created_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["created_by"], name: "index_comments_on_created_by", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "countries", force: true do |t|
    t.string  "name"
    t.string  "abbreviation",     limit: 5
    t.integer "shipping_zone_id"
    t.boolean "active",                     default: false
  end

  add_index "countries", ["active"], name: "index_countries_on_active", using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree
  add_index "countries", ["shipping_zone_id", "active"], name: "index_countries_on_shipping_zone_id_and_active", using: :btree

  create_table "coupons", force: true do |t|
    t.string   "type",                                                  null: false
    t.string   "code",                                                  null: false
    t.decimal  "amount",        precision: 8, scale: 2, default: 0.0
    t.decimal  "minimum_value", precision: 8, scale: 2
    t.integer  "percent",                               default: 0
    t.text     "description",                                           null: false
    t.boolean  "combine",                               default: false
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree
  add_index "coupons", ["expires_at"], name: "index_coupons_on_expires_at", using: :btree

  create_table "deal_types", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", force: true do |t|
    t.integer  "buy_quantity",    null: false
    t.integer  "get_percentage"
    t.integer  "deal_type_id",    null: false
    t.integer  "product_type_id", null: false
    t.integer  "get_amount"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["buy_quantity"], name: "index_deals_on_buy_quantity", using: :btree
  add_index "deals", ["deal_type_id"], name: "index_deals_on_deal_type_id", using: :btree
  add_index "deals", ["product_type_id"], name: "index_deals_on_product_type_id", using: :btree

  create_table "images", force: true do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.integer  "image_height"
    t.integer  "image_width"
    t.integer  "position"
    t.string   "caption"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "images", ["imageable_id"], name: "index_images_on_imageable_id", using: :btree
  add_index "images", ["imageable_type"], name: "index_images_on_imageable_type", using: :btree
  add_index "images", ["position"], name: "index_images_on_position", using: :btree

  create_table "inventories", force: true do |t|
    t.integer "count_on_hand",               default: 0
    t.integer "count_pending_to_customer",   default: 0
    t.integer "count_pending_from_supplier", default: 0
  end

  create_table "invoices", force: true do |t|
    t.integer  "order_id",                                                     null: false
    t.decimal  "amount",          precision: 8, scale: 2,                      null: false
    t.string   "invoice_type",                            default: "Purchase", null: false
    t.string   "state",                                                        null: false
    t.boolean  "active",                                  default: true,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credited_amount", precision: 8, scale: 2, default: 0.0
  end

  add_index "invoices", ["order_id"], name: "index_invoices_on_order_id", using: :btree

  create_table "item_types", force: true do |t|
    t.string "name"
  end

  create_table "newsletters", force: true do |t|
    t.string  "name",          null: false
    t.boolean "autosubscribe", null: false
  end

  create_table "order_items", force: true do |t|
    t.decimal  "price",            precision: 8, scale: 2
    t.decimal  "total",            precision: 8, scale: 2
    t.integer  "order_id",                                 null: false
    t.integer  "variant_id",                               null: false
    t.string   "state",                                    null: false
    t.integer  "tax_rate_id"
    t.integer  "shipping_rate_id"
    t.integer  "shipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["shipment_id"], name: "index_order_items_on_shipment_id", using: :btree
  add_index "order_items", ["shipping_rate_id"], name: "index_order_items_on_shipping_rate_id", using: :btree
  add_index "order_items", ["tax_rate_id"], name: "index_order_items_on_tax_rate_id", using: :btree
  add_index "order_items", ["variant_id"], name: "index_order_items_on_variant_id", using: :btree

  create_table "orders", force: true do |t|
    t.string   "number"
    t.string   "ip_address"
    t.string   "email"
    t.string   "state"
    t.integer  "user_id"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.integer  "coupon_id"
    t.boolean  "active",                                  default: true,  null: false
    t.boolean  "shipped",                                 default: false, null: false
    t.integer  "shipments_count",                         default: 0
    t.datetime "calculated_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credited_amount", precision: 8, scale: 2, default: 0.0
  end

  add_index "orders", ["bill_address_id"], name: "index_orders_on_bill_address_id", using: :btree
  add_index "orders", ["coupon_id"], name: "index_orders_on_coupon_id", using: :btree
  add_index "orders", ["email"], name: "index_orders_on_email", using: :btree
  add_index "orders", ["number"], name: "index_orders_on_number", using: :btree
  add_index "orders", ["ship_address_id"], name: "index_orders_on_ship_address_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payment_profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "address_id"
    t.string   "payment_cim_id"
    t.boolean  "default"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_digits"
    t.string   "month"
    t.string   "year"
    t.string   "cc_type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "card_name"
  end

  add_index "payment_profiles", ["address_id"], name: "index_payment_profiles_on_address_id", using: :btree
  add_index "payment_profiles", ["user_id"], name: "index_payment_profiles_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "invoice_id"
    t.string   "confirmation_id"
    t.integer  "amount"
    t.string   "error"
    t.string   "error_code"
    t.string   "message"
    t.string   "action"
    t.text     "params"
    t.boolean  "success"
    t.boolean  "test"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["invoice_id"], name: "index_payments_on_invoice_id", using: :btree

  create_table "phone_types", force: true do |t|
    t.string "name", null: false
  end

  create_table "phones", force: true do |t|
    t.integer  "phone_type_id"
    t.string   "number",                         null: false
    t.string   "phoneable_type",                 null: false
    t.integer  "phoneable_id",                   null: false
    t.boolean  "primary",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["phone_type_id"], name: "index_phones_on_phone_type_id", using: :btree
  add_index "phones", ["phoneable_id"], name: "index_phones_on_phoneable_id", using: :btree
  add_index "phones", ["phoneable_type"], name: "index_phones_on_phoneable_type", using: :btree

  create_table "product_properties", force: true do |t|
    t.integer "product_id",  null: false
    t.integer "property_id", null: false
    t.integer "position"
    t.string  "description", null: false
  end

  add_index "product_properties", ["product_id"], name: "index_product_properties_on_product_id", using: :btree
  add_index "product_properties", ["property_id"], name: "index_product_properties_on_property_id", using: :btree

  create_table "product_types", force: true do |t|
    t.string  "name",                     null: false
    t.integer "parent_id"
    t.boolean "active",    default: true
    t.integer "rgt"
    t.integer "lft"
  end

  add_index "product_types", ["lft"], name: "index_product_types_on_lft", using: :btree
  add_index "product_types", ["parent_id"], name: "index_product_types_on_parent_id", using: :btree
  add_index "product_types", ["rgt"], name: "index_product_types_on_rgt", using: :btree

  create_table "products", force: true do |t|
    t.string   "name",                                 null: false
    t.text     "description"
    t.text     "product_keywords"
    t.integer  "product_type_id",                      null: false
    t.integer  "prototype_id"
    t.integer  "shipping_category_id",                 null: false
    t.string   "permalink",                            null: false
    t.datetime "available_at"
    t.datetime "deleted_at"
    t.string   "meta_keywords"
    t.string   "meta_description"
    t.boolean  "featured",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description_markup"
    t.integer  "brand_id"
  end

  add_index "products", ["brand_id"], name: "index_products_on_brand_id", using: :btree
  add_index "products", ["deleted_at"], name: "index_products_on_deleted_at", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["permalink"], name: "index_products_on_permalink", unique: true, using: :btree
  add_index "products", ["product_type_id"], name: "index_products_on_product_type_id", using: :btree
  add_index "products", ["prototype_id"], name: "index_products_on_prototype_id", using: :btree
  add_index "products", ["shipping_category_id"], name: "index_products_on_shipping_category_id", using: :btree

  create_table "properties", force: true do |t|
    t.string  "identifing_name",                null: false
    t.string  "display_name"
    t.boolean "active",          default: true
  end

  create_table "prototype_properties", force: true do |t|
    t.integer "prototype_id", null: false
    t.integer "property_id",  null: false
  end

  add_index "prototype_properties", ["property_id"], name: "index_prototype_properties_on_property_id", using: :btree
  add_index "prototype_properties", ["prototype_id"], name: "index_prototype_properties_on_prototype_id", using: :btree

  create_table "prototypes", force: true do |t|
    t.string  "name",                  null: false
    t.boolean "active", default: true, null: false
  end

  create_table "purchase_order_variants", force: true do |t|
    t.integer  "purchase_order_id",                                         null: false
    t.integer  "variant_id",                                                null: false
    t.integer  "quantity",                                                  null: false
    t.decimal  "cost",              precision: 8, scale: 2,                 null: false
    t.boolean  "is_received",                               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_order_variants", ["purchase_order_id"], name: "index_purchase_order_variants_on_purchase_order_id", using: :btree
  add_index "purchase_order_variants", ["variant_id"], name: "index_purchase_order_variants_on_variant_id", using: :btree

  create_table "purchase_orders", force: true do |t|
    t.integer  "supplier_id",                                                null: false
    t.string   "invoice_number"
    t.string   "tracking_number"
    t.string   "notes"
    t.string   "state"
    t.datetime "ordered_at",                                                 null: false
    t.date     "estimated_arrival_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total_cost",           precision: 8, scale: 2, default: 0.0, null: false
  end

  add_index "purchase_orders", ["supplier_id"], name: "index_purchase_orders_on_supplier_id", using: :btree
  add_index "purchase_orders", ["tracking_number"], name: "index_purchase_orders_on_tracking_number", using: :btree

  create_table "referral_bonuses", force: true do |t|
    t.integer  "amount",     null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_programs", force: true do |t|
    t.boolean  "active",            null: false
    t.text     "description"
    t.string   "name",              null: false
    t.integer  "referral_bonus_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referral_programs", ["referral_bonus_id"], name: "index_referral_programs_on_referral_bonus_id", using: :btree

  create_table "referral_types", force: true do |t|
    t.string "name", null: false
  end

  create_table "referrals", force: true do |t|
    t.boolean  "applied",             default: false
    t.datetime "clicked_at"
    t.string   "email",                               null: false
    t.string   "name"
    t.datetime "purchased_at"
    t.integer  "referral_program_id",                 null: false
    t.integer  "referral_type_id",                    null: false
    t.integer  "referral_user_id"
    t.integer  "referring_user_id",                   null: false
    t.datetime "registered_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referrals", ["email"], name: "index_referrals_on_email", length: {"email"=>6}, using: :btree
  add_index "referrals", ["referral_program_id"], name: "index_referrals_on_referral_program_id", using: :btree
  add_index "referrals", ["referral_type_id"], name: "index_referrals_on_referral_type_id", using: :btree
  add_index "referrals", ["referral_user_id"], name: "index_referrals_on_referral_user_id", using: :btree
  add_index "referrals", ["referring_user_id"], name: "index_referrals_on_referring_user_id", using: :btree

  create_table "return_authorizations", force: true do |t|
    t.string   "number"
    t.decimal  "amount",         precision: 8, scale: 2,                null: false
    t.decimal  "restocking_fee", precision: 8, scale: 2, default: 0.0
    t.integer  "order_id",                                              null: false
    t.integer  "user_id",                                               null: false
    t.string   "state",                                                 null: false
    t.integer  "created_by"
    t.boolean  "active",                                 default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "return_authorizations", ["created_by"], name: "index_return_authorizations_on_created_by", using: :btree
  add_index "return_authorizations", ["number"], name: "index_return_authorizations_on_number", using: :btree
  add_index "return_authorizations", ["order_id"], name: "index_return_authorizations_on_order_id", using: :btree
  add_index "return_authorizations", ["user_id"], name: "index_return_authorizations_on_user_id", using: :btree

  create_table "return_conditions", force: true do |t|
    t.string "label"
    t.string "description"
  end

  create_table "return_items", force: true do |t|
    t.integer  "return_authorization_id",                 null: false
    t.integer  "order_item_id",                           null: false
    t.integer  "return_condition_id"
    t.integer  "return_reason_id"
    t.boolean  "returned",                default: false
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "return_items", ["order_item_id"], name: "index_return_items_on_order_item_id", using: :btree
  add_index "return_items", ["return_authorization_id"], name: "index_return_items_on_return_authorization_id", using: :btree
  add_index "return_items", ["return_condition_id"], name: "index_return_items_on_return_condition_id", using: :btree
  add_index "return_items", ["return_reason_id"], name: "index_return_items_on_return_reason_id", using: :btree
  add_index "return_items", ["updated_by"], name: "index_return_items_on_updated_by", using: :btree

  create_table "return_reasons", force: true do |t|
    t.string "label"
    t.string "description"
  end

  create_table "roles", force: true do |t|
    t.string "name", limit: 30, null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sales", force: true do |t|
    t.integer  "product_id"
    t.decimal  "percent_off", precision: 8, scale: 2, default: 0.0
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales", ["product_id"], name: "index_sales_on_product_id", using: :btree

  create_table "shipments", force: true do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id",                null: false
    t.integer  "address_id",                        null: false
    t.string   "tracking"
    t.string   "number",                            null: false
    t.string   "state",                             null: false
    t.datetime "shipped_at"
    t.boolean  "active",             default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipments", ["address_id"], name: "index_shipments_on_address_id", using: :btree
  add_index "shipments", ["number"], name: "index_shipments_on_number", using: :btree
  add_index "shipments", ["order_id"], name: "index_shipments_on_order_id", using: :btree
  add_index "shipments", ["shipping_method_id"], name: "index_shipments_on_shipping_method_id", using: :btree

  create_table "shipping_categories", force: true do |t|
    t.string "name", null: false
  end

  create_table "shipping_methods", force: true do |t|
    t.string   "name",             null: false
    t.integer  "shipping_zone_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_methods", ["shipping_zone_id"], name: "index_shipping_methods_on_shipping_zone_id", using: :btree

  create_table "shipping_rate_types", force: true do |t|
    t.string "name", null: false
  end

  create_table "shipping_rates", force: true do |t|
    t.integer  "shipping_method_id",                                           null: false
    t.decimal  "rate",                  precision: 8, scale: 2, default: 0.0,  null: false
    t.integer  "shipping_rate_type_id",                                        null: false
    t.integer  "shipping_category_id",                                         null: false
    t.decimal  "minimum_charge",        precision: 8, scale: 2, default: 0.0,  null: false
    t.integer  "position"
    t.boolean  "active",                                        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_rates", ["shipping_category_id"], name: "index_shipping_rates_on_shipping_category_id", using: :btree
  add_index "shipping_rates", ["shipping_method_id"], name: "index_shipping_rates_on_shipping_method_id", using: :btree
  add_index "shipping_rates", ["shipping_rate_type_id"], name: "index_shipping_rates_on_shipping_rate_type_id", using: :btree

  create_table "shipping_zones", force: true do |t|
    t.string "name", null: false
  end

  create_table "slugs", force: true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                  default: 1, null: false
    t.string   "sluggable_type", limit: 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true, using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "states", force: true do |t|
    t.string  "name",                       null: false
    t.string  "abbreviation",     limit: 5, null: false
    t.string  "described_as"
    t.integer "country_id",                 null: false
    t.integer "shipping_zone_id",           null: false
  end

  add_index "states", ["abbreviation"], name: "index_states_on_abbreviation", using: :btree
  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree
  add_index "states", ["name"], name: "index_states_on_name", using: :btree

  create_table "store_credits", force: true do |t|
    t.decimal  "amount",     precision: 8, scale: 2, default: 0.0
    t.integer  "user_id",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "store_credits", ["user_id"], name: "index_store_credits_on_user_id", using: :btree

  create_table "suppliers", force: true do |t|
    t.string   "name",       null: false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_rates", force: true do |t|
    t.decimal "percentage", precision: 8, scale: 2, default: 0.0,  null: false
    t.integer "state_id"
    t.integer "country_id"
    t.date    "start_date",                                        null: false
    t.date    "end_date"
    t.boolean "active",                             default: true
  end

  add_index "tax_rates", ["state_id"], name: "index_tax_rates_on_state_id", using: :btree

  create_table "tax_statuses", force: true do |t|
    t.string "name", null: false
  end

  create_table "transaction_accounts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_ledgers", force: true do |t|
    t.string   "accountable_type"
    t.integer  "accountable_id"
    t.integer  "transaction_id"
    t.integer  "transaction_account_id"
    t.decimal  "tax_amount",             precision: 8, scale: 2, default: 0.0
    t.decimal  "debit",                  precision: 8, scale: 2,               null: false
    t.decimal  "credit",                 precision: 8, scale: 2,               null: false
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_ledgers", ["accountable_id"], name: "index_transaction_ledgers_on_accountable_id", using: :btree
  add_index "transaction_ledgers", ["transaction_account_id"], name: "index_transaction_ledgers_on_transaction_account_id", using: :btree
  add_index "transaction_ledgers", ["transaction_id"], name: "index_transaction_ledgers_on_transaction_id", using: :btree

  create_table "transactions", force: true do |t|
    t.string   "type"
    t.integer  "batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["batch_id"], name: "index_transactions_on_batch_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer "role_id", null: false
    t.integer "user_id", null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birth_date"
    t.string   "email"
    t.string   "state"
    t.integer  "account_id"
    t.string   "customer_cim_id"
    t.string   "password_salt"
    t.string   "crypted_password"
    t.string   "perishable_token"
    t.string   "persistence_token"
    t.string   "access_token"
    t.integer  "comments_count",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["perishable_token"], name: "index_users_on_perishable_token", unique: true, using: :btree
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token", unique: true, using: :btree

  create_table "users_newsletters", force: true do |t|
    t.integer  "user_id"
    t.integer  "newsletter_id"
    t.datetime "updated_at",    null: false
  end

  add_index "users_newsletters", ["newsletter_id"], name: "index_users_newsletters_on_newsletter_id", using: :btree
  add_index "users_newsletters", ["user_id"], name: "index_users_newsletters_on_user_id", using: :btree

  create_table "variant_properties", force: true do |t|
    t.integer "variant_id",                  null: false
    t.integer "property_id",                 null: false
    t.string  "description",                 null: false
    t.boolean "primary",     default: false
  end

  add_index "variant_properties", ["property_id"], name: "index_variant_properties_on_property_id", using: :btree
  add_index "variant_properties", ["variant_id"], name: "index_variant_properties_on_variant_id", using: :btree

  create_table "variant_suppliers", force: true do |t|
    t.integer  "variant_id",                                                      null: false
    t.integer  "supplier_id",                                                     null: false
    t.decimal  "cost",                    precision: 8, scale: 2, default: 0.0,   null: false
    t.integer  "total_quantity_supplied",                         default: 0
    t.integer  "min_quantity",                                    default: 1
    t.integer  "max_quantity",                                    default: 10000
    t.boolean  "active",                                          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "variant_suppliers", ["supplier_id"], name: "index_variant_suppliers_on_supplier_id", using: :btree
  add_index "variant_suppliers", ["variant_id"], name: "index_variant_suppliers_on_variant_id", using: :btree

  create_table "variants", force: true do |t|
    t.integer  "product_id",                                           null: false
    t.string   "sku",                                                  null: false
    t.string   "name"
    t.decimal  "price",        precision: 8, scale: 2, default: 0.0,   null: false
    t.decimal  "cost",         precision: 8, scale: 2, default: 0.0,   null: false
    t.datetime "deleted_at"
    t.boolean  "master",                               default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
    t.integer  "inventory_id"
  end

  add_index "variants", ["brand_id"], name: "index_variants_on_brand_id", using: :btree
  add_index "variants", ["inventory_id"], name: "index_variants_on_inventory_id", using: :btree
  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree
  add_index "variants", ["sku"], name: "index_variants_on_sku", using: :btree

end
