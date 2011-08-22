class Myaccount::AddressesController < Myaccount::BaseController
  def index
    @addresses = current_user.addresses
  end

  def show
    @address = current_user.addresses.find(params[:id])
  end

  def new
    form_info
    @address = Address.new
  end

  def create
    @address = current_user.addresses.new(params[:address])
    if @address.save
      flash[:notice] = "Successfully created address."
      redirect_to myaccount_address_url(@address)
    else
      form_info
      render :action => 'new'
    end
  end

  def edit
    form_info
    @address = current_user.addresses.find(params[:id])
  end

  def update
    @address = current_user.addresses.find(params[:id])
    if @address.update_attributes(params[:address])
      flash[:notice] = "Successfully updated address."
      redirect_to myaccount_address_url(@address)
    else
      form_info
      render :action => 'edit'
    end
  end

  def destroy
    @address = current_user.addresses.find(params[:id])
    @address.inactive!
    flash[:notice] = "Successfully destroyed address."
    redirect_to myaccount_addresses_url
  end

  private

  def form_info
    @states = State.form_selector
  end
end
