#ROR Ecommerce

##Project Overview

Please create a ticket on github if you have issues.
They will be addressed ASAP.

Please look at the [homepage](http://www.ror-e.com) for more details.  Or take a look at the [github page](http://drhenner.github.com/ror_ecommerce/index.html)

![RoR Ecommerce](http://ror-e.com/images/logo.png "ROR Ecommerce").
[![Code Climate](https://codeclimate.com/github/drhenner/ror_ecommerce.png)](https://codeclimate.com/github/drhenner/ror_ecommerce)

This is a Rails e-commerce platform.
ROR Ecommerce is a *Rails 4 application* with the intent to allow developers to create an ecommerce solution easily.
This solution includes an Admin for *Purchase Orders*, *Product creation*, *Shipments*, *Fulfillment* and *creating Orders*.
There is a minimal customer facing shopping cart understanding that this will be customized.
The cart allows you to track your customers' *cart history* and includes a *double entry accounting system*.

The project has *Solr searching*, *Compass* and *Zurb Foundation for CSS* and uses *jQuery*.
Currently the most complete Rails solution for your small business.

Please use *Ruby 2.1* and enjoy *Rails 4.1*.

ROR Ecommerce is designed so that if you understand Rails you will understand ROR_ecommerce.
There is nothing in this project besides what you might see in a normal Rails application.
If you don't like something, you are free to just change it like you would in any other Rails app.

**Contributors are welcome!**
We will always need help with UI, documentation, and code, so feel free to pitch in.
To get started, simply fork this repo, make *any* changes (big or small), and create a pull request.

##DEMO

Take a look at [The Demo](https://ror-e.herokuapp.com).
The login name is test@ror-e.com with a password => test123

NOTE: Given that everyone has admin rights to the demo it is frequently looking less than "beautiful".

##Getting Started

Please feel free to ask/answer questions in our [Google Group](http://groups.google.com/group/ror_ecommerce).

Install RVM with Ruby 2.1.
If you have 2.1 on your system you're good to go.
Please refer to the [RVM](http://beginrescueend.com/rvm/basics/) site for more details.

Copy the `database.yml` for your setup.
For SQLite3, `cp config/database.yml.sqlite3 config/database.yml`.
For MySQL, `cp config/database.yml.mysql config/database.yml` and update your username/password.

If you are using the mysql dmg file to install mysql you will need to edit your ~/.bash_profile and include this:

  export DYLD_LIBRARY_PATH=/usr/local/mysql/lib:$DYLD_LIBRARY_PATH

Run `rake secret` and copy/paste the output as `encryption_key` in `config/config.yml`.

    gem install bundler
    bundle install
    rake db:create:all
    rake db:migrate db:seed
    RAILS_ENV=test rake db:test:prepare

Once everything is set up, start the server with `rails server` and direct your web browser to [localhost:3000/admin/overviews](http://localhost:3000/admin/overviews).
Write down the username/password (these are only shown once) and follow the directions.

## Environmental Variables

Most users are using Amazon S3 or Heroku.
Thus we have decided to have a setup easy to get your site up and running as quickly as possible
in this production environment.  Hence you should add the following ENV variables:

    FOG_DIRECTORY     => your bucket on AWS
    AWS_ACCESS_KEY_ID => your access key on AWS
    AWS_ACCESS_KEY_ID => your secret key on AWS
    AUTHNET_LOGIN     => if you use authorize.net otherwise change config/settings.yml && config/environments/*.rb
    AUTHNET_PASSWORD  => if you use authorize.net otherwise change config/settings.yml && config/environments/*.rb

On linux:

    export FOG_DIRECTORY=xxxxxxxxxxxxxxx
    export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
    export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    export AUTHNET_LOGIN=xxxxxxxxxxx
    export AUTHNET_PASSWORD=xxxxxxxxxxxxxxx

On Heroku:

    heroku config:add FOG_DIRECTORY=xxxxxxxxxxxxxxx
    heroku config:add AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxx
    heroku config:add AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    heroku config:add AUTHNET_LOGIN=xxxxxxxxxxx
    heroku config:add AUTHNET_PASSWORD=xxxxxxxxxxxxxxx

    heroku labs:enable user-env-compile -a myapp

This is needed for using sendgrid on heroku(config/initializers/mail.rb):

    heroku config:add SENDGRID_USERNAME=xxxxxxxxxxx
    heroku config:add SENDGRID_PASSWORD=xxxxxxxxxxxxxxx


##Quick Evaluation

If you just want to see what ror_ecommerce looks like, before you enter any products into the database, run the following command:

    rake db:seed_fake

If you have not already done so point your browser to http://lvh.me:3000/admin/overviews and set up the admin user.

You should now have a minimal dataset, and be able to see a demo of the various parts of the app.
Note: make sure you have `config/settings.yml` set up correctly before you try to checkout.
Also, please take a look at [The 15 minute e-commerce video](http://www.ror-e.com/info/videos/7).

##ImageMagick and rMagick on OS X 10.8
------------------------------------

If installing rMagick on OS X 10.8 and using Homebrew to install ImageMagick, you will need to symlink across some files or rMagick will not be able to build.

Do the following in the case of a Homebrew installed ImageMagick(and homebrew had issues):

    * cd /usr/local/Cellar/imagemagick/6.8.0-10/lib
    * ln -s libMagick++-Q16.7.dylib   libMagick++.dylib
    * ln -s libMagickCore-Q16.7.dylib libMagickCore.dylib
    * ln -s libMagickWand-Q16.7.dylib libMagickWand.dylib

##YARDOCS

If you would like to read the docs, you can generate them with the following command:

    yardoc --no-private --protected app/models/*.rb

####Payment Gateways

First, create `config/settings.yml` and change the encryption key and paypal/auth.net information.
You can also change `config/settings.yml.example` to `config/settings.yml` until you get your real info.

To change from authlogic to any other gateway look at the documentation [HERE](http://drhenner.github.com/ror_ecommerce/config.html)

## Paperclip

Paperclip will throw errors if not configured correctly.
You will need to find out where Imagemagick is installed.
Type: `which identify` in the terminal and set

```ruby
Paperclip.options[:command_path]
```

equal to that path in `config/paperclip.rb`.

Example:

Change:

```ruby
Paperclip.options[:command_path] = "/usr/local/bin"
```

Into:

```ruby
Paperclip.options[:command_path] = "/usr/bin"
```

##Adding Dalli For Cache and the Session Store

While optional, for a speedy site, using memcached is a good idea.

Install memcached.
If you're on a Mac, the easiest way to install Memcached is to use [homebrew](http://mxcl.github.com/homebrew/):

    brew install memcached

    memcached -vv

####To Turn On the Dalli Cookie Store

Remove the cookie store on line one of `config/initializers/session_store.rb`.
In your Gemfile add:

```ruby
gem 'dalli'
```

then:

    bundle install

Finally uncomment the next two lines in `config/initializers/session_store.rb`

```ruby
require 'action_dispatch/middleware/session/dalli_store'
Hadean::Application.config.session_store :dalli_store, :key => '_hadean_session_ugrdr6765745ce4vy'
```

####To Turn On the Dalli Cache Store

It is also recommended to change the cache store in config/environments/*.rb

```ruby
config.cache_store = :dalli_store
```

## Adding Solr Search

    brew install solr

Uncomment the following in your gemfile:

```ruby
#gem 'sunspot_solr'
#gem 'sunspot_rails'
```

then:

    bundle install

Start Solr before starting your server:

    rake sunspot:solr:start

Go to `product.rb` and uncomment:

```ruby
#include ProductSolr
```

Also remove the method:
```ruby
def self.standard_search
```

Take a look at setting up Solr - [Solr in 5 minutes](http://github.com/outoftime/sunspot/wiki/adding-sunspot-search-to-rails-in-5-minutes-or-less)

If you get the error, `Errno::ECONNREFUSED (Connection refused - connect(2)):` when you try to create a product or upload an image, you have not started Solr search.
You need to run `rake sunspot:solr:start`, or remove Solr completely.

Remember to run `rake sunspot:reindex` before doing your search if you already have data in the DB

##TODO:

* more documentation


##SETUP assets on S3 with CORS

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


##Author

RoR Ecommerce was created by David Henner. [Contributors](https://github.com/drhenner/ror_ecommerce/blob/master/Contributors.md).

##FYI:

Shipping categories are categories based off price:

you might have two shipping categories (light items) & (heavy items) where heavy items are charged per item purchased and light items are charged once for all items purchased.  (hence buying 30 feathers has the same shipping charges as one feather)

Have fun!!!
