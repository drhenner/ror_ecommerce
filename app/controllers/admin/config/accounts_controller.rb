class Admin::Config::AccountsController < Admin::Config::BaseController
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(admin_config_account_url(@account), :notice => 'Account was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to(admin_config_account_url(@account), :notice => 'Account was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to(admin_config_accounts_url)
  end
end
