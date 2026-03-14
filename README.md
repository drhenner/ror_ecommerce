# ROR Ecommerce

## Project Overview

Please create a ticket on github if you have issues.
They will be addressed ASAP.

This is a Rails e-commerce platform.
ROR Ecommerce is a *Rails 7.0 application* with the intent to allow developers to create an ecommerce solution easily.
This solution includes an Admin for *Purchase Orders*, *Product creation*, *Shipments*, *Fulfillment* and *creating Orders*.
There is a minimal customer facing shopping cart understanding that this will be customized.
The cart allows you to track your customers' *cart history* and includes a *double entry accounting system*.

The project has *Solr searching* and *Zurb Foundation for CSS* and uses *jQuery*.
Currently the most complete Rails solution for your small business.

Please use *Ruby 3.1.4* and enjoy *Rails 7.0*.

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

Install RVM with Ruby 3.1.4.
If you have 3.1.4 on your system you're good to go.
Please refer to the [RVM](http://beginrescueend.com/rvm/basics/) site for more details.

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
You can also change `config/settings.yml.example` to `config/settings.yml` until you get your real info.

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

## Adding Solr Search (Optional)

Solr search is **not enabled by default**. The Sunspot gems are not in the Gemfile. To add Solr search:

1. Add the gems to your Gemfile:

```ruby
gem 'sunspot_solr'
gem 'sunspot_rails'
```

2. Install and start Solr:

```bash
brew install solr
bundle install
bundle exec rake sunspot:solr:start
```

3. In `app/models/product.rb`, uncomment:

```ruby
#include ProductSolr
```

and remove the `self.standard_search` method.

Take a look at setting up Solr - [Solr in 5 minutes](http://github.com/outoftime/sunspot/wiki/adding-sunspot-search-to-rails-in-5-minutes-or-less)

If you get the error `Errno::ECONNREFUSED (Connection refused - connect(2)):` when you try to create a product, you have not started Solr search.
Run `bundle exec rake sunspot:solr:start`, or remove Solr completely.

Remember to run `bundle exec rake sunspot:reindex` before doing your search if you already have data in the DB

## Running Tests

The test suite uses RSpec with a MySQL test database. Before running tests for the first time:

```bash
RAILS_ENV=test rails db:create db:migrate db:seed
```

Then run the full suite:

```bash
bundle exec rspec
```

**Note:** One product-creation spec requires Solr to be running (`bundle exec rake sunspot:solr:start`). All other specs pass without Solr.

## TODO:

* more documentation
* Add Solid Cache support when upgrading to Rails 8


## SETUP assets on S3 with CORS

Putting assets on S3 can cause issues with FireFox/IE.  You can read about the issue if you search for "S3 & CORS".  Basically FF & IE are keeping things more secure but in the process you are required to do some setup.

I ran into the same thing with assets not being public for IE and FireFox but Chrome seemed to work fine. There is a work around for this though. There is something called a CORS Config that opens up your assets to whatever domains you specify.

Here's how to open up your assets to your website.  (Thanks @DTwigs)

* Click on your bucket.
* Click on the properties button to open the properties tab.
* Expand the "Permissions" accordion and click " Add CORS Configuration"

Now paste this code in there:

    <?xml version="1.0" encoding="UTF-8"?>
    <CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <MaxAgeSeconds>3000</MaxAgeSeconds>
    <AllowedHeader>Content-*</AllowedHeader>
    <AllowedHeader>Host</AllowedHeader>
    </CORSRule>
    </CORSConfiguration>

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
