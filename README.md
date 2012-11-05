#ROR Ecommerce

##Project Overview

Please create a ticket on github if you have issues.
They will be addressed ASAP.

Please look at the [homepage](http://www.ror-e.com) for more details.

![RoR Ecommerce](http://ror-e.com/images/logo.png "ROR Ecommerce").

This is a Rails e-commerce platform. Other e-commerce projects that use rails don't use rails in a standard way.
They use engines or are a separate framework altogether.

ROR Ecommerce is a *Rails 3 application* with the intent to allow developers to create an ecommerce solution easily.
This solution includes an Admin for *Purchase Orders*, *Product creation*, *Shipments*, *Fulfillment* and *creating Orders*.
There is a minimal customer facing shopping cart understanding that this will be customized.
The cart allows you to track your customers' *cart history* and includes a *double entry accounting system*.

The project has *Solr searching*, *Compass* and *Blueprint for CSS* and uses *jQuery*.
The gem list is quite large and the project still has a large wish list.
In spite of that, it is currently the most complete Rails solution, and it will only get better.

Please use *Ruby 1.9.2* and enjoy *Rails 3.2*.

ROR Ecommerce is designed so that if you understand Rails you will understand ROR_ecommerce.
There is nothing in this project besides what you might see in a normal Rails application.
If you don't like something, you are free to just change it like you would in any other Rails app.

Contributors are welcome!
We will always need help with UI, documentation, and code, so feel free to pitch in.
To get started, simply fork this repo, make *any* changes (big or small), and create a pull request.

##Getting Started

Please feel free to ask/answer questions in our [Google Group](http://groups.google.com/group/ror_ecommerce).

Install RVM with Ruby 1.9.2 or Ruby 1.9.3.
If you have 1.9.2 or 1.9.3 on your system you're good to go.
Please refer to the [RVM](http://beginrescueend.com/rvm/basics/) site for more details.

Copy the `database.yml` for your setup.
For SQLite3, `cp config/database.yml.sqlite3 config/database.yml`.
For MySQL, `cp config/database.yml.mysql config/database.yml` and update your username/password.

Run `rake secret` and copy/paste the output as `encryption_key` in `config/config.yml`.

    gem install bundler
    bundle install
    rake db:create:all
    rake db:migrate db:seed
    rake db:test:prepare

Once everything is set up, start the server with `rails server` and direct your web browser to [localhost:3000/admin/overviews](http://localhost:3000/admin/overviews).
Write down the username/password (these are only shown once) and follow the directions.

##Quick Evaluation

If you just want to see what ror_ecommerce looks like, before you enter any products into the database, run the following command:

    rake db:seed_fake

You should now have a minimal dataset, and be able to see a demo of the various parts of the app.
Note: make sure you have `config/settings.yml` set up correctly before you try to checkout.
Also, please take a look at [The 15 minute e-commerce video](http://www.ror-e.com/info/videos/7).

##YARDOCS

If you would like to read the docs, you can generate them with the following command:

    yardoc --no-private --protected app/models/*.rb

####Compass Install

First, create `config/settings.yml` and change the encryption key and paypal/auth.net information.
You can also change `config/settings.yml.example` to `config/settings.yml` until you get your real info.

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
#gem 'sunspot_rails', '~> 1.3'
```

then:

    bundle install

Start Solr before starting your server:

    rake sunspot:solr:start

Go to the bottom of `product.rb` and uncomment:

```ruby
Product.class_eval
```

Take a look at setting up Solr - [Solr in 5 minutes](http://github.com/outoftime/sunspot/wiki/adding-sunspot-search-to-rails-in-5-minutes-or-less)

If you get the error, `Errno::ECONNREFUSED (Connection refused - connect(2)):` when you try to create a product or upload an image, you have not started Solr search.
You need to run `rake sunspot:solr:start`, or remove Solr completely.

##TODO:

* product sales (eg. 20% off)
* more documentation / videos for creating products/variants

##Author

RoR Ecommerce was created by David Henner. [Contributors](https://github.com/drhenner/ror_ecommerce/blob/master/Contributors.md).

##FYI:

Shipping categories are categories based off price:

you might have two shipping categories (light items) & (heavy items)

Have fun!!!
