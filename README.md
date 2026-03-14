# ROR Ecommerce

## Project Overview

Please create a ticket on github if you have issues.
They will be addressed ASAP.

This is a Rails e-commerce platform.
ROR Ecommerce is a *Rails 8.1 application* with the intent to allow developers to create an ecommerce solution easily.
This solution includes an Admin for *Purchase Orders*, *Product creation*, *Shipments*, *Fulfillment* and *creating Orders*.
There is a minimal customer facing shopping cart understanding that this will be customized.
The cart allows you to track your customers' *cart history* and includes a *double entry accounting system*.

The project has *Searchkick-powered product search* (backed by Elasticsearch), *Zurb Foundation for CSS*, and uses *jQuery*.
Currently the most complete Rails solution for your small business.

Please use *Ruby 3.3.8* and enjoy *Rails 8.1*.

ROR Ecommerce is designed so that if you understand Rails you will understand ROR_ecommerce.
There is nothing in this project besides what you might see in a normal Rails application.
If you don't like something, you are free to just change it like you would in any other Rails app.

**Contributors are welcome!**
We will always need help with UI, documentation, and code, so feel free to pitch in.
To get started, simply fork this repo, make *any* changes (big or small), and create a pull request.

## DEMO

Take a look at [The Demo](https://ror-e.herokuapp.com).
The login name is test@ror-e.com with a password => test123

NOTE: Given that everyone has admin rights to the demo it is frequently looking less than "beautiful".

## Getting Started

Please feel free to ask/answer questions in our [Google Group](http://groups.google.com/group/ror_ecommerce).

Install Ruby 3.3.8 using a version manager such as [rbenv](https://github.com/rbenv/rbenv) or [RVM](http://rvm.io/).
If you already have 3.3.8 on your system you're good to go.

Copy the `database.yml` for your setup.
For SQLite3, `cp config/database.yml.sqlite3 config/database.yml`.
For MySQL, `cp config/database.yml.mysql config/database.yml` and update your username/password.

If you are using the mysql dmg file to install mysql you will need to edit your ~/.bash_profile and include this:

  export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH

Install gems and build the app

    gem install bundler
    bundle install
    rails secret # copy/paste the output as `encryption_key` in `config/settings.yml`
    rails db:create:all
    rails db:migrate db:seed
    rails dartsass:build
    RAILS_ENV=test rails db:test:prepare
    RAILS_ENV=test rails db:seed

Once everything is set up, start the server with `rails server` and direct your web browser to [localhost:3000/admin/overviews](http://localhost:3000/admin/overviews).
Write down the username/password (these are only shown once) and follow the directions.

## Environmental Variables

Most users are using Amazon S3 or Heroku.
Thus we have decided to have a setup easy to get your site up and running as quickly as possible
in this production environment.  Hence you should add the following ENV variables:

    S3_BUCKET_NAME        => your bucket on AWS (or FOG_DIRECTORY for backward compat)
    AWS_ACCESS_KEY_ID     => your access key on AWS
    AWS_SECRET_ACCESS_KEY => your secret key on AWS
    AWS_REGION            => your AWS region (defaults to us-east-1)
    AUTHNET_LOGIN         => if you use authorize.net otherwise change config/settings.yml && config/environments/*.rb
    AUTHNET_PASSWORD      => if you use authorize.net otherwise change config/settings.yml && config/environments/*.rb

On linux:

    export S3_BUCKET_NAME=xxxxxxxxxxxxxxx
    export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
    export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    export AWS_REGION=us-east-1
    export AUTHNET_LOGIN=xxxxxxxxxxx
    export AUTHNET_PASSWORD=xxxxxxxxxxxxxxx

On Heroku:

    heroku config:set S3_BUCKET_NAME=xxxxxxxxxxxxxxx
    heroku config:set AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
    heroku config:set AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    heroku config:set AWS_REGION=us-east-1
    heroku config:set AUTHNET_LOGIN=xxxxxxxxxxx
    heroku config:set AUTHNET_PASSWORD=xxxxxxxxxxxxxxx

This is needed for using sendgrid on heroku(config/initializers/mail.rb):

    heroku config:set SENDGRID_USERNAME=xxxxxxxxxxx
    heroku config:set SENDGRID_PASSWORD=xxxxxxxxxxxxxxx


## Quick Evaluation

If you just want to see what ror_ecommerce looks like, before you enter any products into the database, run the following command:

    rails db:seed_fake

If you have not already done so point your browser to http://lvh.me:3000/admin/overviews and set up the admin user.

You should now have a minimal dataset, and be able to see a demo of the various parts of the app.
Note: make sure you have `config/settings.yml` set up correctly before you try to checkout.
Also, please take a look at [The 15 minute e-commerce video](http://www.ror-e.com/info/videos/7).

## YARDOCS

If you would like to read the docs, you can generate them with the following command:

    yardoc --no-private --protected app/models/*.rb

#### Payment Gateways

First, create `config/settings.yml` and change the encryption key and paypal/auth.net information.
You can also change `config/settings.example.yml` to `config/settings.yml` until you get your real info.

To change from authlogic to any other gateway look at the documentation [HERE](http://drhenner.github.com/ror_ecommerce/config.html)

## Image Uploads (Active Storage)

Product images are handled by Active Storage. Storage backends are configured in `config/storage.yml` (disk for development/test, S3 for production).

The `Image` model uses `has_one_attached :photo` and provides variant sizes via `Image::IMAGE_STYLES`. Use `image.photo_url(:small)` to get a resized variant.

For image processing to work, you need the `image_processing` gem (included in the Gemfile) and either `libvips` or ImageMagick installed locally:

```bash
# macOS (libvips recommended)
brew install vips

# or ImageMagick
brew install imagemagick
```

## Product Search (Searchkick + Elasticsearch)

Product search is powered by [Searchkick](https://github.com/ankane/searchkick), which uses Elasticsearch under the hood. It provides typo-tolerant, relevance-ranked full-text search across product names, keywords, and descriptions.

### How it works

The `Product` model includes the `ProductSearch` concern (`app/models/concerns/product_search.rb`), which:

- Declares `searchkick word_start: [:name]` for autocomplete-friendly matching on product names
- Indexes `name` (boosted 2x), `product_keywords`, `description_markup`, and `deleted_at`
- Provides `Product.standard_search(query, page:, per_page:)` used by the storefront search (`ProductsController#create`)
- Falls back to a SQL `LIKE` query if Elasticsearch is unreachable, so the app remains functional without ES running

### Setup

1. Install and start Elasticsearch:

```bash
brew install elasticsearch
brew services start elasticsearch
```

2. Reindex products (required after initial seed or any time you want to rebuild the index):

```bash
rails runner "Product.reindex"
```

The `db:seed_fake` rake task automatically reindexes products after seeding.

### Elasticsearch is optional for development

If Elasticsearch is not running, product search degrades gracefully to SQL `LIKE` queries on `products.name` and `products.meta_keywords`. Admin product grids (`Product.admin_grid`) do not use Elasticsearch at all.

## Running Tests

The test suite uses RSpec with a MySQL test database. Before running tests for the first time:

```bash
RAILS_ENV=test rails db:create db:migrate db:seed
rails dartsass:build
```

Then run the full suite:

```bash
bundle exec rspec
```

### Searchkick in tests

Searchkick callbacks are **disabled globally** in `spec_helper.rb` (`Searchkick.disable_callbacks` in `before(:each)`, re-enabled in `after(:each)`). This means:

- **Elasticsearch does not need to be running** to run the test suite. Product saves skip indexing entirely.
- Search specs exercise the SQL fallback path by default, which verifies that search degrades gracefully.
- If you need to test actual Elasticsearch search behavior in a spec, enable callbacks and reindex within the test:

```ruby
it "returns matching products from Elasticsearch" do
  Searchkick.enable_callbacks
  product = FactoryBot.create(:product, name: "Red Widget")
  Product.reindex
  results = Product.standard_search("Red Widget")
  expect(results).to include(product)
end
```

## Admin Roles & Permissions

The admin area uses [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization, defined in `app/models/admin_ability.rb`. There are five admin roles:

| Role | Key Permissions |
|------|----------------|
| **Super Admin** (`super_admin?`) | Full read/write access to everything (`can :manage, :all`) |
| **Admin** (`admin?`) | Read-only on all resources, plus view users, create orders, manage fulfillment, and manage coupons |
| **Warehouse** (`warehouse?`) | Read products/variants, manage purchase orders, manage fulfillment, read orders |
| **Customer Service** (`customer_service?`) | Read orders and users, view users, manage return authorizations |
| **Report** (`report?`) | Read-only access to reports |

### Adding new admin abilities

Edit `app/models/admin_ability.rb` and add `can` rules under the appropriate role block. Controllers that need explicit checks should call `authorize!` or use `authorize_resource`. See the [CanCanCan docs](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/README.md) for details.

## Asset Pipeline

The app uses **Propshaft** for serving assets, **dartsass-rails** for compiling SCSS to CSS, and **importmap-rails** for future JavaScript module support. jQuery and its plugins are loaded as traditional script tags.

After changing any `.scss` file, rebuild CSS with:

    rails dartsass:build

In development, you can run the watcher to auto-compile on save:

    rails dartsass:watch

Compiled CSS is output to `app/assets/builds/` (gitignored). Propshaft serves these alongside static assets from `app/assets/`, `vendor/assets/`, and `vendor/javascript/`.

## Rails 8.1 Upgrade Notes

The application was upgraded from Rails 8.0 to Rails 8.1.2. Key changes:

- **Framework defaults**: `config.load_defaults 8.1` with two legacy overrides in `config/application.rb` (`belongs_to_required_by_default = false` and `action_on_open_redirect = :log`).
- **Schema sorting**: `db/schema.rb` columns are now sorted alphabetically (Rails 8.1 default).
- **Form helpers**: `number_field` and `number_field_tag` no longer accept a separate HTML options hash as a third argument. All options must be merged into a single hash (e.g. `f.number_field :qty, step: 1, class: "form-control"`).
- **Open redirects**: `raise_on_open_redirects` was deprecated in favor of `action_on_open_redirect`.
- **Removed defaults files**: `new_framework_defaults_7_0.rb` and `new_framework_defaults_8_0.rb` have been removed; their overrides are consolidated in `config/application.rb`.

## Wireframes

The `wireframes/` directory contains standalone HTML mockups for anyone looking to give the app a fresh look and feel. Open them directly in a browser for a quick preview.

**Admin layouts:**

- [Option A — Sidebar Dashboard](wireframes/option_a_sidebar_dashboard.html) — collapsible left sidebar with icon+label navigation
- [Option B — Top-Nav Command Palette](wireframes/option_b_topnav_command_palette.html) — horizontal top nav with a spotlight-style search
- [Option C — Two-Tier Hybrid](wireframes/option_c_two_tier_hybrid.html) — slim icon sidebar + horizontal sub-nav tabs

**Storefront layouts:**

- [Storefront A — Minimal Editorial](wireframes/storefront_a_minimal_editorial.html) — clean, whitespace-driven product grid
- [Storefront B — Magazine Storytelling](wireframes/storefront_b_magazine_storytelling.html) — hero-image-forward, editorial-style layout

These are starting points for inspiration — pick one, remix it, or build your own.

## TODO:

* more documentation
* Evaluate migrating from Authlogic to Rails' built-in `has_secure_password` + `authenticate_by`
* Evaluate Solid Cache / Solid Queue for background jobs and caching

## Image Groups

Typically a product has many variants.  (Variant ~= specific size of a given shoe)

If you have many variants with the same image don't bother with an image group, just use the "products.images".

Use ImageGroups for something like shoes. Lets say you have 3 colors, and each color has 10 sizes. You would create 3 images groups (one for each color). The image for each size would be the same and hence each variant would be associated to the same image_group for a given color.

## Author

RoR Ecommerce was created by David Henner. [Contributors](https://github.com/drhenner/ror_ecommerce/blob/master/Contributors.md).

## FYI:

Shipping categories are categories based off price:

you might have two shipping categories (light items) & (heavy items) where heavy items are charged per item purchased and light items are charged once for all items purchased.  (hence buying 30 feathers has the same shipping charges as one feather)

Have fun!!!
