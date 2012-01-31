#ROR Ecommerce

##Project Overview

Please create a ticket if on github you have issues.  They will be addressed ASAP.

[Please look at the homepage for more details](http://www.ror-e.com)

![Alt text](http://ror-e.com/images/logo.png "ROR Ecommerce")

This is a Rails e-commerce platform.  Other e-commerce projects that use rails, don't use rails in a standard way.  They use engines or are a separate framework altogether.

ROR ecommerce is a *Rails 3 application* with the intent to allow developers to create an ecommerce solution easily.  This solution includes, an Admin for  *Purchase Orders*, *Product creation*, *Shipments*, *Fulfillment* and *creating Orders*.  There is a minimal customer facing shopping cart understanding that this will be customized.  The cart allows you to track your customers *cart history* and includes a *double entry accounting system*.

The project has *solr searching*, *compass* and *blueprint for CSS* and uses *jQuery*. The gem list is quite large and the project still has a large wish list but it is the most complete solution for Rails today and it will only get better.

Please use *Ruby 1.9.2* and enjoy *Rails 3.2*.

ROR_ecommerce is designed differently. If you understand Rails you will understand ROR_ecommerce.
There is nothing in this project that you wouldn't see in a normal Rails application.  If you don't like what is in the project just change it like you would in any other Rails app.

Contributors are welcome.  For now email David Henner (*drhenner@yahoo.com*) to see how you can contribute. (send your patch if you have one.)  Soon there will be a bug tracking system and a formal way to submit your patch.

We will always need help with UI, Documentation and code so feel free to help.

##Getting Started

We have a google group.  Ask question and help answer questions.
[ror_ecommerce Google-group](http://groups.google.com/group/ror_ecommerce)

Install rvm with ruby 1.9.2 or if you have 1.9.2 on your system you're good to go. Please refer to the [rvm](http://beginrescueend.com/rvm/basics/) and [bundler](http://gembundler.com) home pages for more details.

Configure your database.yml file (add the development and test database)

* Go into config/config.yml and change the encryption_key

    $ dd if=/dev/urandom bs=1 count=75 2> /dev/null | xxd -p -c75

  will display some random characters like this: Copy what it gives you and paste it under `encryption_key`

`f5317296f3420d698de775dc5675b193f35fdbac576540888a0ae2628fcfb59646d7ef83da76afbb1f8ea7fb70acea887549e475aa7c869b1f82353f12dbad8bd517c941b981bf936772f0`


* gem install bundler
* bundle install
* rake db:create
* rake db:migrate
* rake db:seed
* rake db:test:prepare

##Quick Evaluation

If you just want to see what ror_ecommerce looks like, before you enter and products into the database run the following command:

* rake db:seed_fake

Now you should have a minimal dataset to go through the various parts of the app.  Make should you have the config/config.yml setup before you try to checkout though.  Also take a look at [The 15 minute e-commerce video](http://www.ror-e.com/info/videos/7)

##YARDOCS

If you would like to see the docs you can generate them locally with the following command:

    yardoc --no-private --protected app/models/*.rb

####compass install

Need to create config/config.yml and change the encryption key and paypal or auth.net information.
You can also change config/config.yml.example to config/config.yml until you get your real info.

Paperclip will throw errors if not configured correctly. You will need to find out where Imagemagick is installed.
Type `which identify` in the terminal and set `Paperclip.options[:command_path] equal` to that path in environment.rb: Examples:

    Paperclip.options[:command_path] = "/usr/local/bin"
into:
    Paperclip.options[:command_path] = "/usr/bin"


Once everything is setup, start up the server with 'rails server' and direct it to

[localhost:3000/admin/overviews](http://localhost:3000/admin/overviews)

write down the username/password and follow the directions.

##Adding Dalli for cache and the session store

Install memcached, If you're on a Mac, the easiest way to install Memcached is to use [homebrew](http://mxcl.github.com/homebrew/) and run:

    brew install memcached

    memcached -vv

####TO TURN ON THE DALLI COOKIE STORE

Remove the cookie store on line one of config/initializers/session_store.rb go to the Gemfile and add

    gem 'dalli'

then

    bundle install

Finally UNCOMMENT the next 2 lines in config/initializers/session_store.rb

    require 'action_dispatch/middleware/session/dalli_store'
    Hadean::Application.config.session_store :dalli_store, :key => '_hadean_session_ugrdr6765745ce4vy'

####TO TURN ON THE DALLI CACHE STORE

It is also recommended to change the cache store in config/environments/*.rb

    config.cache_store = :dalli_store



## Adding Solr Search


    brew install solr

Uncomment the following in your gemfile

    #gem 'sunspot_solr'
    #gem 'sunspot_rails', '~> 1.3'

then

    bundle install

start solr before starting you server
    rake sunspot:solr:start

Go to the *bottom of product.rb* and uncomment the section with *"Product.class_eval"*


Take a look at setting up solr
[Solr in 5 minutes](http://github.com/outoftime/sunspot/wiki/adding-sunspot-search-to-rails-in-5-minutes-or-less)


If you get the following error:
    Errno::ECONNREFUSED (Connection refused - connect(2)):
when you try to create a product or upload an image you have not started solr search, remember you need to run `rake sunspot:solr:start` or remove solr/search

##Before You Deploy

Many deploy processes require db/schema.rb to be checked into version control.  schema.rb was remove from git because this allowed ror_ecommerce users to rebase easily.  Add schema.rb back to version control before you deploy.

##TODOs:

* product sales (eg. 20% off)
* more documentation / videos for creating products/variants
* easy setup of fake data for getting started

##Author

RoR Ecommerce was written by David Henner:

To view contributors look at Contributors.textile

##FYI:

Shipping categories are categories based off price:

you might have two shipping categories (light items) & (heavy items)
Have fun!!!

