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

ActiveRecord::Schema.define(version: 20131123212228) do

  create_table "accounting_adjustments", force: :cascade do |t|
    t.integer  "adjustable_id",   limit: 4,                           null: false
    t.string   "adjustable_type", limit: 255,                         null: false
    t.string   "notes",           limit: 255
    t.decimal  "amount",                      precision: 8, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounting_adjustments", ["adjustable_id"], name: "index_accounting_adjustments_on_adjustable_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.string   "name",           limit: 255,                                        null: false
    t.string   "account_type",   limit: 255,                                        null: false
    t.decimal  "monthly_charge",             precision: 8, scale: 2, default: 0.0,  null: false
    t.boolean  "active",         limit: 1,                           default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "address_types", force: :cascade do |t|
    t.string "name",        limit: 64,  null: false
    t.string "description", limit: 255
  end

  add_index "address_types", ["name"], name: "index_address_types_on_name", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "address_type_id",   limit: 4
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "addressable_type",  limit: 255,                 null: false
    t.integer  "addressable_id",    limit: 4,                   null: false
    t.string   "address1",          limit: 255,                 null: false
    t.string   "address2",          limit: 255
    t.string   "city",              limit: 255,                 null: false
    t.integer  "state_id",          limit: 4
    t.string   "state_name",        limit: 255
    t.string   "zip_code",          limit: 255,                 null: false
    t.integer  "phone_id",          limit: 4
    t.string   "alternative_phone", limit: 255
    t.boolean  "default",           limit: 1,   default: false
    t.boolean  "billing_default",   limit: 1,   default: false
    t.boolean  "active",            limit: 1,   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id",        limit: 4
  end

  add_index "addresses", ["addressable_id"], name: "index_addresses_on_addressable_id", using: :btree
  add_index "addresses", ["addressable_type"], name: "index_addresses_on_addressable_type", using: :btree
  add_index "addresses", ["state_id"], name: "index_addresses_on_state_id", using: :btree

  create_table "batches", force: :cascade do |t|
    t.string   "batchable_type", limit: 255
    t.integer  "batchable_id",   limit: 4
    t.string   "name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "batches", ["batchable_id"], name: "index_batches_on_batchable_id", using: :btree
  add_index "batches", ["batchable_type"], name: "index_batches_on_batchable_type", using: :btree

  create_table "brands", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "cart_id",      limit: 4
    t.integer  "variant_id",   limit: 4,                null: false
    t.integer  "quantity",     limit: 4, default: 1
    t.boolean  "active",       limit: 1, default: true
    t.integer  "item_type_id", limit: 4,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["item_type_id"], name: "index_cart_items_on_item_type_id", using: :btree
  add_index "cart_items", ["user_id"], name: "index_cart_items_on_user_id", using: :btree
  add_index "cart_items", ["variant_id"], name: "index_cart_items_on_variant_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id", limit: 4
  end

  add_index "carts", ["customer_id"], name: "index_carts_on_customer_id", using: :btree
  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "note",             limit: 65535
    t.string   "commentable_type", limit: 255
    t.integer  "commentable_id",   limit: 4
    t.integer  "created_by",       limit: 4
    t.integer  "user_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["created_by"], name: "index_comments_on_created_by", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string  "name",             limit: 255
    t.string  "abbreviation",     limit: 5
    t.integer "shipping_zone_id", limit: 4
    t.boolean "active",           limit: 1,   default: false
  end

  add_index "countries", ["active"], name: "index_countries_on_active", using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree
  add_index "countries", ["shipping_zone_id", "active"], name: "index_countries_on_shipping_zone_id_and_active", using: :btree

  create_table "coupons", force: :cascade do |t|
    t.string   "type",          limit: 255,                                           null: false
    t.string   "code",          limit: 255,                                           null: false
    t.decimal  "amount",                      precision: 8, scale: 2, default: 0.0
    t.decimal  "minimum_value",               precision: 8, scale: 2
    t.integer  "percent",       limit: 4,                             default: 0
    t.text     "description",   limit: 65535,                                         null: false
    t.boolean  "combine",       limit: 1,                             default: false
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coupons", ["code"], name: "index_coupons_on_code", using: :btree
  add_index "coupons", ["expires_at"], name: "index_coupons_on_expires_at", using: :btree

  create_table "deal_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deals", force: :cascade do |t|
    t.integer  "buy_quantity",    limit: 4, null: false
    t.integer  "get_percentage",  limit: 4
    t.integer  "deal_type_id",    limit: 4, null: false
    t.integer  "product_type_id", limit: 4, null: false
    t.integer  "get_amount",      limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["buy_quantity"], name: "index_deals_on_buy_quantity", using: :btree
  add_index "deals", ["deal_type_id"], name: "index_deals_on_deal_type_id", using: :btree
  add_index "deals", ["product_type_id"], name: "index_deals_on_product_type_id", using: :btree

  create_table "image_groups", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "product_id", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "image_groups", ["product_id"], name: "index_image_groups_on_product_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "imageable_id",       limit: 4
    t.string   "imageable_type",     limit: 255
    t.integer  "image_height",       limit: 4
    t.integer  "image_width",        limit: 4
    t.integer  "position",           limit: 4
    t.string   "caption",            limit: 255
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "images", ["imageable_id"], name: "index_images_on_imageable_id", using: :btree
  add_index "images", ["imageable_type"], name: "index_images_on_imageable_type", using: :btree
  add_index "images", ["position"], name: "index_images_on_position", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer "count_on_hand",               limit: 4, default: 0
    t.integer "count_pending_to_customer",   limit: 4, default: 0
    t.integer "count_pending_from_supplier", limit: 4, default: 0
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "order_id",        limit: 4,                                                null: false
    t.decimal  "amount",                      precision: 8, scale: 2,                      null: false
    t.string   "invoice_type",    limit: 255,                         default: "Purchase", null: false
    t.string   "state",           limit: 255,                                              null: false
    t.boolean  "active",          limit: 1,                           default: true,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credited_amount",             precision: 8, scale: 2, default: 0.0
  end

  add_index "invoices", ["order_id"], name: "index_invoices_on_order_id", using: :btree

  create_table "item_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "newsletters", force: :cascade do |t|
    t.string  "name",          limit: 255, null: false
    t.boolean "autosubscribe", limit: 1,   null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.decimal  "price",                        precision: 8, scale: 2
    t.decimal  "total",                        precision: 8, scale: 2
    t.integer  "order_id",         limit: 4,                           null: false
    t.integer  "variant_id",       limit: 4,                           null: false
    t.string   "state",            limit: 255,                         null: false
    t.integer  "tax_rate_id",      limit: 4
    t.integer  "shipping_rate_id", limit: 4
    t.integer  "shipment_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["shipment_id"], name: "index_order_items_on_shipment_id", using: :btree
  add_index "order_items", ["shipping_rate_id"], name: "index_order_items_on_shipping_rate_id", using: :btree
  add_index "order_items", ["tax_rate_id"], name: "index_order_items_on_tax_rate_id", using: :btree
  add_index "order_items", ["variant_id"], name: "index_order_items_on_variant_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "number",          limit: 255
    t.string   "ip_address",      limit: 255
    t.string   "email",           limit: 255
    t.string   "state",           limit: 255
    t.integer  "user_id",         limit: 4
    t.integer  "bill_address_id", limit: 4
    t.integer  "ship_address_id", limit: 4
    t.integer  "coupon_id",       limit: 4
    t.boolean  "active",          limit: 1,                           default: true,  null: false
    t.boolean  "shipped",         limit: 1,                           default: false, null: false
    t.integer  "shipments_count", limit: 4,                           default: 0
    t.datetime "calculated_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credited_amount",             precision: 8, scale: 2, default: 0.0
  end

  add_index "orders", ["bill_address_id"], name: "index_orders_on_bill_address_id", using: :btree
  add_index "orders", ["coupon_id"], name: "index_orders_on_coupon_id", using: :btree
  add_index "orders", ["email"], name: "index_orders_on_email", using: :btree
  add_index "orders", ["number"], name: "index_orders_on_number", using: :btree
  add_index "orders", ["ship_address_id"], name: "index_orders_on_ship_address_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "payment_profiles", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.integer  "address_id",     limit: 4
    t.string   "payment_cim_id", limit: 255
    t.boolean  "default",        limit: 1
    t.boolean  "active",         limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_digits",    limit: 255
    t.string   "month",          limit: 255
    t.string   "year",           limit: 255
    t.string   "cc_type",        limit: 255
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.string   "card_name",      limit: 255
  end

  add_index "payment_profiles", ["address_id"], name: "index_payment_profiles_on_address_id", using: :btree
  add_index "payment_profiles", ["user_id"], name: "index_payment_profiles_on_user_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "invoice_id",      limit: 4
    t.string   "confirmation_id", limit: 255
    t.integer  "amount",          limit: 4
    t.string   "error",           limit: 255
    t.string   "error_code",      limit: 255
    t.string   "message",         limit: 255
    t.string   "action",          limit: 255
    t.text     "params",          limit: 65535
    t.boolean  "success",         limit: 1
    t.boolean  "test",            limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["invoice_id"], name: "index_payments_on_invoice_id", using: :btree

  create_table "phone_types", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "phones", force: :cascade do |t|
    t.integer  "phone_type_id",  limit: 4
    t.string   "number",         limit: 255,                 null: false
    t.string   "phoneable_type", limit: 255,                 null: false
    t.integer  "phoneable_id",   limit: 4,                   null: false
    t.boolean  "primary",        limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["phone_type_id"], name: "index_phones_on_phone_type_id", using: :btree
  add_index "phones", ["phoneable_id"], name: "index_phones_on_phoneable_id", using: :btree
  add_index "phones", ["phoneable_type"], name: "index_phones_on_phoneable_type", using: :btree

  create_table "product_properties", force: :cascade do |t|
    t.integer "product_id",  limit: 4,   null: false
    t.integer "property_id", limit: 4,   null: false
    t.integer "position",    limit: 4
    t.string  "description", limit: 255, null: false
  end

  add_index "product_properties", ["product_id"], name: "index_product_properties_on_product_id", using: :btree
  add_index "product_properties", ["property_id"], name: "index_product_properties_on_property_id", using: :btree

  create_table "product_types", force: :cascade do |t|
    t.string  "name",      limit: 255,                null: false
    t.integer "parent_id", limit: 4
    t.boolean "active",    limit: 1,   default: true
    t.integer "rgt",       limit: 4
    t.integer "lft",       limit: 4
  end

  add_index "product_types", ["lft"], name: "index_product_types_on_lft", using: :btree
  add_index "product_types", ["parent_id"], name: "index_product_types_on_parent_id", using: :btree
  add_index "product_types", ["rgt"], name: "index_product_types_on_rgt", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",                 limit: 255,                   null: false
    t.text     "description",          limit: 65535
    t.text     "product_keywords",     limit: 65535
    t.integer  "product_type_id",      limit: 4,                     null: false
    t.integer  "prototype_id",         limit: 4
    t.integer  "shipping_category_id", limit: 4,                     null: false
    t.string   "permalink",            limit: 255,                   null: false
    t.datetime "available_at"
    t.datetime "deleted_at"
    t.string   "meta_keywords",        limit: 255
    t.string   "meta_description",     limit: 255
    t.boolean  "featured",             limit: 1,     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description_markup",   limit: 65535
    t.integer  "brand_id",             limit: 4
  end

  add_index "products", ["brand_id"], name: "index_products_on_brand_id", using: :btree
  add_index "products", ["deleted_at"], name: "index_products_on_deleted_at", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["permalink"], name: "index_products_on_permalink", unique: true, using: :btree
  add_index "products", ["product_type_id"], name: "index_products_on_product_type_id", using: :btree
  add_index "products", ["prototype_id"], name: "index_products_on_prototype_id", using: :btree
  add_index "products", ["shipping_category_id"], name: "index_products_on_shipping_category_id", using: :btree

  create_table "properties", force: :cascade do |t|
    t.string  "identifing_name", limit: 255,                null: false
    t.string  "display_name",    limit: 255
    t.boolean "active",          limit: 1,   default: true
  end

  create_table "prototype_properties", force: :cascade do |t|
    t.integer "prototype_id", limit: 4, null: false
    t.integer "property_id",  limit: 4, null: false
  end

  add_index "prototype_properties", ["property_id"], name: "index_prototype_properties_on_property_id", using: :btree
  add_index "prototype_properties", ["prototype_id"], name: "index_prototype_properties_on_prototype_id", using: :btree

  create_table "prototypes", force: :cascade do |t|
    t.string  "name",   limit: 255,                null: false
    t.boolean "active", limit: 1,   default: true, null: false
  end

  create_table "purchase_order_variants", force: :cascade do |t|
    t.integer  "purchase_order_id", limit: 4,                                         null: false
    t.integer  "variant_id",        limit: 4,                                         null: false
    t.integer  "quantity",          limit: 4,                                         null: false
    t.decimal  "cost",                        precision: 8, scale: 2,                 null: false
    t.boolean  "is_received",       limit: 1,                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_order_variants", ["purchase_order_id"], name: "index_purchase_order_variants_on_purchase_order_id", using: :btree
  add_index "purchase_order_variants", ["variant_id"], name: "index_purchase_order_variants_on_variant_id", using: :btree

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "supplier_id",          limit: 4,                                         null: false
    t.string   "invoice_number",       limit: 255
    t.string   "tracking_number",      limit: 255
    t.string   "notes",                limit: 255
    t.string   "state",                limit: 255
    t.datetime "ordered_at",                                                             null: false
    t.date     "estimated_arrival_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total_cost",                       precision: 8, scale: 2, default: 0.0, null: false
  end

  add_index "purchase_orders", ["supplier_id"], name: "index_purchase_orders_on_supplier_id", using: :btree
  add_index "purchase_orders", ["tracking_number"], name: "index_purchase_orders_on_tracking_number", using: :btree

  create_table "referral_bonuses", force: :cascade do |t|
    t.integer  "amount",     limit: 4,   null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_programs", force: :cascade do |t|
    t.boolean  "active",            limit: 1,     null: false
    t.text     "description",       limit: 65535
    t.string   "name",              limit: 255,   null: false
    t.integer  "referral_bonus_id", limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referral_programs", ["referral_bonus_id"], name: "index_referral_programs_on_referral_bonus_id", using: :btree

  create_table "referral_types", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "referrals", force: :cascade do |t|
    t.boolean  "applied",             limit: 1,   default: false
    t.datetime "clicked_at"
    t.string   "email",               limit: 255,                 null: false
    t.string   "name",                limit: 255
    t.datetime "purchased_at"
    t.integer  "referral_program_id", limit: 4,                   null: false
    t.integer  "referral_type_id",    limit: 4,                   null: false
    t.integer  "referral_user_id",    limit: 4
    t.integer  "referring_user_id",   limit: 4,                   null: false
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

  create_table "return_authorizations", force: :cascade do |t|
    t.string   "number",         limit: 255
    t.decimal  "amount",                     precision: 8, scale: 2,                null: false
    t.decimal  "restocking_fee",             precision: 8, scale: 2, default: 0.0
    t.integer  "order_id",       limit: 4,                                          null: false
    t.integer  "user_id",        limit: 4,                                          null: false
    t.string   "state",          limit: 255,                                        null: false
    t.integer  "created_by",     limit: 4
    t.boolean  "active",         limit: 1,                           default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "return_authorizations", ["created_by"], name: "index_return_authorizations_on_created_by", using: :btree
  add_index "return_authorizations", ["number"], name: "index_return_authorizations_on_number", using: :btree
  add_index "return_authorizations", ["order_id"], name: "index_return_authorizations_on_order_id", using: :btree
  add_index "return_authorizations", ["user_id"], name: "index_return_authorizations_on_user_id", using: :btree

  create_table "return_conditions", force: :cascade do |t|
    t.string "label",       limit: 255
    t.string "description", limit: 255
  end

  create_table "return_items", force: :cascade do |t|
    t.integer  "return_authorization_id", limit: 4,                 null: false
    t.integer  "order_item_id",           limit: 4,                 null: false
    t.integer  "return_condition_id",     limit: 4
    t.integer  "return_reason_id",        limit: 4
    t.boolean  "returned",                limit: 1, default: false
    t.integer  "updated_by",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "return_items", ["order_item_id"], name: "index_return_items_on_order_item_id", using: :btree
  add_index "return_items", ["return_authorization_id"], name: "index_return_items_on_return_authorization_id", using: :btree
  add_index "return_items", ["return_condition_id"], name: "index_return_items_on_return_condition_id", using: :btree
  add_index "return_items", ["return_reason_id"], name: "index_return_items_on_return_reason_id", using: :btree
  add_index "return_items", ["updated_by"], name: "index_return_items_on_updated_by", using: :btree

  create_table "return_reasons", force: :cascade do |t|
    t.string "label",       limit: 255
    t.string "description", limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 30, null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sales", force: :cascade do |t|
    t.integer  "product_id",  limit: 4
    t.decimal  "percent_off",           precision: 8, scale: 2, default: 0.0
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales", ["product_id"], name: "index_sales_on_product_id", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id",           limit: 4
    t.integer  "shipping_method_id", limit: 4,                  null: false
    t.integer  "address_id",         limit: 4,                  null: false
    t.string   "tracking",           limit: 255
    t.string   "number",             limit: 255,                null: false
    t.string   "state",              limit: 255,                null: false
    t.datetime "shipped_at"
    t.boolean  "active",             limit: 1,   default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipments", ["address_id"], name: "index_shipments_on_address_id", using: :btree
  add_index "shipments", ["number"], name: "index_shipments_on_number", using: :btree
  add_index "shipments", ["order_id"], name: "index_shipments_on_order_id", using: :btree
  add_index "shipments", ["shipping_method_id"], name: "index_shipments_on_shipping_method_id", using: :btree

  create_table "shipping_categories", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.string   "name",             limit: 255, null: false
    t.integer  "shipping_zone_id", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_methods", ["shipping_zone_id"], name: "index_shipping_methods_on_shipping_zone_id", using: :btree

  create_table "shipping_rate_types", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "shipping_rates", force: :cascade do |t|
    t.integer  "shipping_method_id",    limit: 4,                                        null: false
    t.decimal  "rate",                            precision: 8, scale: 2, default: 0.0,  null: false
    t.integer  "shipping_rate_type_id", limit: 4,                                        null: false
    t.integer  "shipping_category_id",  limit: 4,                                        null: false
    t.decimal  "minimum_charge",                  precision: 8, scale: 2, default: 0.0,  null: false
    t.integer  "position",              limit: 4
    t.boolean  "active",                limit: 1,                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipping_rates", ["shipping_category_id"], name: "index_shipping_rates_on_shipping_category_id", using: :btree
  add_index "shipping_rates", ["shipping_method_id"], name: "index_shipping_rates_on_shipping_method_id", using: :btree
  add_index "shipping_rates", ["shipping_rate_type_id"], name: "index_shipping_rates_on_shipping_rate_type_id", using: :btree

  create_table "shipping_zones", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "slugs", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "sluggable_id",   limit: 4
    t.integer  "sequence",       limit: 4,   default: 1, null: false
    t.string   "sluggable_type", limit: 40
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], name: "index_slugs_on_n_s_s_and_s", unique: true, using: :btree
  add_index "slugs", ["sluggable_id"], name: "index_slugs_on_sluggable_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string  "name",             limit: 255, null: false
    t.string  "abbreviation",     limit: 5,   null: false
    t.string  "described_as",     limit: 255
    t.integer "country_id",       limit: 4,   null: false
    t.integer "shipping_zone_id", limit: 4,   null: false
  end

  add_index "states", ["abbreviation"], name: "index_states_on_abbreviation", using: :btree
  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree
  add_index "states", ["name"], name: "index_states_on_name", using: :btree

  create_table "store_credits", force: :cascade do |t|
    t.decimal  "amount",               precision: 8, scale: 2, default: 0.0
    t.integer  "user_id",    limit: 4,                                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "store_credits", ["user_id"], name: "index_store_credits_on_user_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.decimal "percentage",           precision: 8, scale: 2, default: 0.0,  null: false
    t.integer "state_id",   limit: 4
    t.integer "country_id", limit: 4
    t.date    "start_date",                                                  null: false
    t.date    "end_date"
    t.boolean "active",     limit: 1,                         default: true
  end

  add_index "tax_rates", ["state_id"], name: "index_tax_rates_on_state_id", using: :btree

  create_table "tax_statuses", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "transaction_accounts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_ledgers", force: :cascade do |t|
    t.string   "accountable_type",       limit: 255
    t.integer  "accountable_id",         limit: 4
    t.integer  "transaction_id",         limit: 4
    t.integer  "transaction_account_id", limit: 4
    t.decimal  "tax_amount",                         precision: 8, scale: 2, default: 0.0
    t.decimal  "debit",                              precision: 8, scale: 2,               null: false
    t.decimal  "credit",                             precision: 8, scale: 2,               null: false
    t.string   "period",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_ledgers", ["accountable_id"], name: "index_transaction_ledgers_on_accountable_id", using: :btree
  add_index "transaction_ledgers", ["transaction_account_id"], name: "index_transaction_ledgers_on_transaction_account_id", using: :btree
  add_index "transaction_ledgers", ["transaction_id"], name: "index_transaction_ledgers_on_transaction_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.integer  "batch_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["batch_id"], name: "index_transactions_on_batch_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer "role_id", limit: 4, null: false
    t.integer "user_id", limit: 4, null: false
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",        limit: 255
    t.string   "last_name",         limit: 255
    t.string   "email",             limit: 255
    t.string   "state",             limit: 255
    t.integer  "account_id",        limit: 4
    t.string   "customer_cim_id",   limit: 255
    t.string   "password_salt",     limit: 255
    t.string   "crypted_password",  limit: 255
    t.string   "perishable_token",  limit: 255
    t.string   "persistence_token", limit: 255
    t.string   "access_token",      limit: 255
    t.integer  "comments_count",    limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["perishable_token"], name: "index_users_on_perishable_token", unique: true, using: :btree
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token", unique: true, using: :btree

  create_table "users_newsletters", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "newsletter_id", limit: 4
    t.datetime "updated_at",              null: false
  end

  add_index "users_newsletters", ["newsletter_id"], name: "index_users_newsletters_on_newsletter_id", using: :btree
  add_index "users_newsletters", ["user_id"], name: "index_users_newsletters_on_user_id", using: :btree

  create_table "variant_properties", force: :cascade do |t|
    t.integer "variant_id",  limit: 4,                   null: false
    t.integer "property_id", limit: 4,                   null: false
    t.string  "description", limit: 255,                 null: false
    t.boolean "primary",     limit: 1,   default: false
  end

  add_index "variant_properties", ["property_id"], name: "index_variant_properties_on_property_id", using: :btree
  add_index "variant_properties", ["variant_id"], name: "index_variant_properties_on_variant_id", using: :btree

  create_table "variant_suppliers", force: :cascade do |t|
    t.integer  "variant_id",              limit: 4,                                         null: false
    t.integer  "supplier_id",             limit: 4,                                         null: false
    t.decimal  "cost",                              precision: 8, scale: 2, default: 0.0,   null: false
    t.integer  "total_quantity_supplied", limit: 4,                         default: 0
    t.integer  "min_quantity",            limit: 4,                         default: 1
    t.integer  "max_quantity",            limit: 4,                         default: 10000
    t.boolean  "active",                  limit: 1,                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "variant_suppliers", ["supplier_id"], name: "index_variant_suppliers_on_supplier_id", using: :btree
  add_index "variant_suppliers", ["variant_id"], name: "index_variant_suppliers_on_variant_id", using: :btree

  create_table "variants", force: :cascade do |t|
    t.integer  "product_id",     limit: 4,                                           null: false
    t.string   "sku",            limit: 255,                                         null: false
    t.string   "name",           limit: 255
    t.decimal  "price",                      precision: 8, scale: 2, default: 0.0,   null: false
    t.decimal  "cost",                       precision: 8, scale: 2, default: 0.0,   null: false
    t.datetime "deleted_at"
    t.boolean  "master",         limit: 1,                           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id",   limit: 4
    t.integer  "image_group_id", limit: 4
  end

  add_index "variants", ["inventory_id"], name: "index_variants_on_inventory_id", using: :btree
  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree
  add_index "variants", ["sku"], name: "index_variants_on_sku", using: :btree

end
