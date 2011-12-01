Hadean::Application.routes.draw do # |map|

  resources :user_sessions, :only => [:new, :create, :destroy]

  match 'admin'   => 'admin/overviews#index'
  match 'login'   => 'user_sessions#new'
  match 'logout'  => 'user_sessions#destroy'
  match 'signup'  => 'customer/registrations#new'
  match 'admin/merchandise' => 'admin/merchandise/summary#index'
  resources :products, :only => [:index, :show, :create]
  #resources :cart_items
  resources :wish_items,  :only => [:index, :destroy]
  resources :states,      :only => [:index]
  resource :about,        :only => [:show]
  resources :terms,       :only => [:index]

  #devise_for :admins
  #devise_for :admins, :controllers => { :sessions => "admin/sessions" }
  #resources :admins
  #devise_for :users


  root :to => "welcome#index"

  namespace :customer do
    resources :registrations,   :only => [:new, :create]
    resource  :password_reset,  :only => [:new, :create, :edit, :update]
    resource  :activation,      :only => [:show]
  end

  namespace :myaccount do
    resources :orders, :only => [:index, :show]
    resources :addresses
    resources :credit_cards
    resource  :store_credit, :only => [:show]
    resource  :overview, :only => [:show]
  end

  namespace :shopping do
    resources  :cart_items do
      member do
        put :move_to
      end
    end
    resource  :coupon, :only => [:show, :create]
    resources  :orders do
      member do
        get :checkout
      end
    end
    resources  :shipping_methods
    resources  :addresses do
      member do
        put :select_address
      end
    end

  end

  namespace :admin do
    resources :users
    resources :overviews, :only => [:index]


    namespace :rma do
      resources  :orders do
        resources  :return_authorizations do
          member do
            put :complete
          end
        end
      end
      #resources  :shipments
    end

    namespace :history do
      resources  :orders, :only => [:index, :show] do
        resources  :addresses, :only => [:index, :show, :edit, :update, :new, :create]
      end
    end

    namespace :fulfillment do
      resources  :orders do
        resources  :comments
      end
      resources  :shipments do
        member do
          put :ship
        end
        resources  :addresses , :only => [:edit, :update]# This is for editing the shipment address
      end
    end
    namespace :shopping do
      resources :carts
      #resources :billing_addresses
      #resources :credit_cards
      resources :products
      #resources :shipping_addresses
      #resources :shipping_methods
      resources :users
      namespace :checkout do
        resources :billing_addresses, :only => [:index, :update, :new, :create, :select_address] do
          member do
            put :select_address
          end
        end
        resources :credit_cards
        resource  :order, :only => [:show, :update, :start_checkout_process] do
          member do
            post :start_checkout_process
          end
        end
        resources :shipping_addresses, :only => [:index, :update, :new, :create, :select_address] do
          member do
            put :select_address
          end
        end
        resources :shipping_methods, :only => [:index, :update]
      end
    end
    namespace :config do
      resources :accounts
      resources :overviews
      resources :shipping_categories
      resources :shipping_rates
      resources :shipping_methods
      resources :shipping_zones
      resources :tax_rates
      resources :tax_statuses
    end

    namespace :generic do
      resources :coupons
    end
    namespace :inventory do
      resources :suppliers
      resources :overviews
      resources :purchase_orders
      resources :receivings
      resources :adjustments
    end

    namespace :merchandise do
      namespace :images do
        resources :products
      end
      resources :properties
      resources :prototypes
      resources :brands
      resources :product_types
      resources :prototype_properties

      namespace :changes do
        resources :products do
          resource :property,          :only => [:edit, :update]
        end
      end

      namespace :wizards do
        resources :brands,              :only => [:index, :create, :update]
        resources :products,            :only => [:new, :create]
        resources :properties,          :only => [:index, :create, :update]
        resources :prototypes,          :only => [:update]
        resources :tax_statuses,        :only => [:index, :create, :update]
        resources :shipping_categories, :only => [:index, :create, :update]
        resources :product_types,       :only => [:index, :create, :update]
      end

      namespace :multi do
        resources :products do
          resource :variant,      :only => [:edit, :update]
        end
      end
      resources :products do
        member do
          get :add_properties
          put :activate
        end
        resources :variants
      end
      namespace :products do
        resources :descriptions, :only => [:edit, :update]
      end
    end
    namespace :document do
      resources :invoices
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
