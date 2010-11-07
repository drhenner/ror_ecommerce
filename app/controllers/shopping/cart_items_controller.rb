class Shopping::CartItemsController < Shopping::BaseController

  # GET /shopping/cart_items
  # GET /shopping/cart_items.xml
  def index
    @cart_items       = session_cart.shopping_cart_items
    @saved_cart_items = session_cart.saved_cart_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cart_items }
    end
  end

  # GET /shopping/cart_items/1
  # GET /shopping/cart_items/1.xml
  def show
    @cart_item = session_cart.shopping_cart_items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cart_item }
    end
  end

  # GET /shopping/cart_items/new
  # GET /shopping/cart_items/new.xml
  def new
    @cart_item = CartItem.new(:user_id => current_user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cart_item }
    end
  end

  # GET /carts/1/edit
  def edit
    @cart_item = session_cart.shopping_cart_items.find(params[:id])
  end

  # POST /shopping/cart_items
  # POST /shopping/cart_items.xml
  def create
    @cart_item = get_new_cart_item
    session_cart.save if session_cart.new_record?
    if cart_item = session_cart.add_variant(params[:cart_item][:variant_id], most_likely_user)
      flash[:notice] = [I18n.t('out_of_stock_notice'), I18n.t('item_saved_for_later')].compact.join(' ') unless cart_item.shopping_cart_item?
      session_cart.save_user(most_likely_user)
      redirect_to(shopping_cart_items_url)
    else
      variant = Variant.includes(:product).find_by_id(params[:cart_item][:variant_id])
      if variant
        redirect_to(product_url(variant.product))
      else
        flash[:notice] = "Sorry something went wrong"
        redirect_to(root_url())
      end 
    end
  end

  # PUT /carts/1
  # PUT /carts/1.xml
  def update
    @cart_item = session_cart.shopping_cart_items.find(params[:id])

    respond_to do |format|
      if @cart_item.update_attributes(params[:cart_item])
        format.html { redirect_to(@cart_item, :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cart_item.errors, :status => :unprocessable_entity }
      end
    end
  end
## TODO
  ## This method moves saved_cart_items to your shopping_cart_items or saved_cart_items
  #   this method is called using AJAX and returns json. with the object moved, 
  #   otherwise false is returned if there is an error
  #   method => PUT
  def move_to
    
  end

  # DELETE /carts/1
  # DELETE /carts/1.xml
  def destroy
    session_cart.remove_variant(params[:variant_id]) if params[:variant_id]
    redirect_to(shopping_cart_items_url)
  end
  
  private
  
  def get_new_cart_item
    if current_user
      session_cart.cart_items.new(params[:cart_item].merge({:user_id => current_user.id}))
    else
      ###  ADD to session cart
      session_cart.cart_items.new(params[:cart_item])
    end
  end
  
end
