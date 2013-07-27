class Admin::UserDatas::AddressesController < Admin::UserDatas::BaseController
  helper_method :sort_column, :sort_direction, :customer, :select_countries, :select_states
  def index
    @addresses = customer.addresses.order(sort_column + " " + sort_direction).
                         paginate(:page => pagination_page, :per_page => pagination_rows)
  end

  def show
    @address = customer.addresses.find(params[:id])
  end

  def new
    @address = Address.new
    if !Settings.require_state_in_address && countries.size == 1
      @address.country = countries.first
    end
    @address.default = true          if customer.default_shipping_address.nil?
    @form_address = @address
  end

  def create
    @address = customer.addresses.new(allowed_params)
    @address.default = true          if customer.default_shipping_address.nil?
    @address.billing_default = true  if customer.default_billing_address.nil?

    respond_to do |format|
      if @address.save
        format.html { redirect_to([:admin, :user_datas, customer, @address], :notice => 'Address was successfully created.') }
      else
        @form_address = @address
        format.html { render :action => "new" }
      end
    end
  end

  def edit
    @form_address = @address = customer.addresses.find(params[:id])
  end

  # This is not normal because you should never Update an address.
  #   THE ADDRESS could point to an existing order which needs to keep the same address
  def update
    @address = customer.addresses.new(allowed_params)
    @address.replace_address_id = params[:id] # This makes the address we are updating inactive if we save successfully

    # if we are editing the current default address then this is the default address
    @address.default         = true if params[:id].to_i == customer.default_shipping_address.try(:id)
    @address.billing_default = true if params[:id].to_i == customer.default_billing_address.try(:id)

    respond_to do |format|
      if @address.save
        format.html { redirect_to([:admin, :user_datas, customer, @address], :notice => 'Address was successfully updated.') }
      else
        # the form needs to have an id
        @form_address = customer.addresses.find(params[:id])
        # the form needs to reflect the attributes to customer entered
        @form_address.attributes = allowed_params
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @address = customer.addresses.find(params[:id])
    @address.inactive!
    redirect_to admin_user_datas_user_addresses_url(customer), :notice => "Successfully inactivated address."
  end

  private


    def allowed_params
      params.require(:address).permit(:first_name, :last_name, :address1, :address2, :city, :state_id, :state_name, :zip_code, :default, :billing_default, :country_id)
    end

    def customer
      @customer ||= User.includes(:addresses).find(params[:user_id])
    end

    def select_countries
      @select_countries ||= Country.active
    end

    def select_states
      @select_states ||= State.form_selector
    end

    def sort_column
      Address.column_names.include?(params[:sort]) ? params[:sort] : "address_type_id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
