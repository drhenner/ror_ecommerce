### 2.1.0
* RAILS 4.2
* Remove statemachine in favor of AASM
* upgrade many gems (including rspec)
* RUBY 2.1.5
* Security fix for POSTGRES

### 2.0.1
* RAILS 4.0.4
* upgrade gems
* autofill more on checkout
* show all invoices created for an order in admin
* edit shipping zone in admin
* bugs (purchase )
* merge carts after signing in
* better UI

### 2.0.0beta1

* RAILS 4.0.0.rc1 YEAH BABY!
* RUBY 2.0 WOW!!

### 1.5.0 2013-04-19
* confirmation page for GA
* referrals
* reporting tab in admin
* Admin Nav -- see the last 12 users you clicked on
* Performance and Bug enhancements
* newsletters and an un-subscribe link
* Google Analytics funnel
* Better css on product page
* Refactor product search
* Gem upgrades

### 1.4.3 2013-02-04
* bug fixes creating product

### 1.4.2 2013-02-03
* pagination has less duplication
* make UI look better in the admin and Customer facing site
* random bugs
* move removing credits and other code to the models
* clean up code (remove lines on code that aren't doing anything)
* upgrade gems (authlogic)
* Make it dead simple to move to AWS/Heroku
* Change implementation of updating addresses to inactivate old addresses

### 1.4.1 2013-01-13
* Remove the remaining Blueprint CSS

### 1.4.0 2013-01-11
* Added ZURB to customer facing site
* remove blueprint CSS
* Rails 3.2.11 security fix all good

### 1.3.0 2013-01-04
* better css in admin
* Sales
* Refactored Coupon admin page
* Fix Deal bug
* Taxes work at the order level.
* Added Tests for inventory
* Bug Fixes.
* Use Setting instead of config.yml
* documented the models better

### 1.2.1 2012-09-08
* bug in admin properties

### 1.2.0 2012-09-08
* HUGE Admin redesign (DEAN PERRY)  Thank you!
* Deals
* Support for future rails 4.0 deprecations
* BUG fixes

### 1.1.0 2012-06-26
* Add Deals (Buy 5 get 6th for 50% off)
* Change TaxStatus to TaxCategory
* More fulfillment functionality (create new shipment if it hasn't been created)
* Better looking admin UI
* BUG - coupon at a given time
* BUG - reset PAssword
* BUG - Name regex
* BUG creditcard months should be all months

### 1.0.0 2012-02-14

* Small bug with saving default address not saving correctly

### 1.0.0rc3 2012-02-12

* Better looking MyAccounts Section
* Prevent careless deleting of ShippingZones/rate/tax info/brand
* Easier install (no yard docs by default..  Breaks with older MAC's)
* Asset pipeline fixes in production
* Compass Upgrade involved fixes
* Bug with adding multiple properties in wizard
* Rails 3.2
* Clean out Gems
* better Readme

### 1.0.0rc2 2012-01-21

* Bug Fix: RMA process broken link
* remove jqGrid and replaced with normal rails helpers
* added pretty_table to most admin UI for consistent look and feel
* use rails 3.1 ssl
* updated gems (cancan, Zentest)
* asset pipeline needed updates during production to precompile

### 1.0.0rc1 2012-01-16

* Bug Fix: Updating roles
* Bug Fix: Shipping methods in checkout process
* Bug Fix: Navigation (mostly in admin)
* Bug Fix: TEST TIME
* Use the ASET PIPELINE!!!
* redirect after login (if you were required to login)
* readme updates

### 0.10.0 2011-12-04

* Added wizard to create a product
* css / prettier buttons in admin
* add brand to product(not just variant)
* create fake seed data for testing
* remove need for prototypes
* remove yard docs from checked in code
* easier creation of variants
* default meta data

### 0.9.2 2011-11-24

* Add VAT support

### 0.9.1 2011-11-23

* Updated Products workflow to be multistep
* only show active products

### 0.9.0 2011-11-21

* Readme improvements
* removed Solr as a requirement
* remove memcached as a requirement
* ability to add memcached and Solr easily
* UI improvements in the Admin area
* various bugs
* quick setup for evaluation

### 0.9.0rc1 2011-11-12

* CHANGED admin cart to look like the regular cart
* bugs in checkout process
* starting to remove formtastic

### 0.8.0 2011-11-02

* Better shipments and fulfillment UI
* remove unused code/views
* upgrade to rails 3.1
* upgrade most gems to the current versions

### 0.7.0 2011-07-30

* Inventory is now its own model...  TODO move inventory methods to the correct model(from variants)

### 0.6.1 2011-05-10

* description_markup is required for tests to pass (validates presence)

### 0.6.0 2011-05-09

* Description of products use bluecloth so you can easily create HTML.
* bug fix in shipping zones
* upgrade jQuery and rails
* change users to active
* password field showed password fixed bug

### 0.5.0 2011-04-04

* Smarter error messages
* switch to dalli for memcached
* more validations(length of strings) and indexing
* Product types are a nested_set
* Add footer
* Clean up Gemfile
* Coupons have an admin UI and a front end option to connect to the checkout.
* Date parsing works like ruby 1.8.7
* code clean up

### 0.4.0 2011-01-22

* Store Credits can be use to purchase items
* UI improvements
* Much better Cart
* View products by product_type

### 0.3.0 2010-12-30

* YARD docs complete
* admin grid pagination fix

### 0.2.0 2010-12-26

* more YARD docs
* completed admin_grid tests
* better looking home page
* no_image has many sizes now

### 00.01.04 2010-12-19

* added YARD docs
* bug fixed for selecting countries that are available
* Add spain as a country
* Add contributors page
* birthdate needs to parse US-date
* use only taxrates for available countries
* better look an feel on the header

### 00.01.03 2010-12-01

* able to print a basic invoice for an order
* installed prawnto

### 00.01.02 2010-11-21

* able to add countries specific states
* tax rates can be configured per the country of choice
* custom version of nifty generators
* bug fixes for bad pages to add admin forms
* bug fix - welcome page blows up if there aren't any products

### 00.01.01 2010-11-12

* connected Purchase Order to double entry accounting system
* fixed bugs with editing purchase order screen was a blank screen

### 0.1.0 2010-11-12

* Initial version.  This public repo had not been tag with a version yet.  Required for logistics.
