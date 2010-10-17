class Shopping::PaymentsController < Shopping::BaseController
  # GET /shopping/payments
  # GET /shopping/payments.xml
  def index
    @shopping_payments = Shopping::Payment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shopping_payments }
    end
  end

  # GET /shopping/payments/1
  # GET /shopping/payments/1.xml
  def show
    @shopping_payment = Shopping::Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shopping_payment }
    end
  end

  # GET /shopping/payments/new
  # GET /shopping/payments/new.xml
  def new
    @shopping_payment = Shopping::Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shopping_payment }
    end
  end

  # GET /shopping/payments/1/edit
  def edit
    @shopping_payment = Shopping::Payment.find(params[:id])
  end

  # POST /shopping/payments
  # POST /shopping/payments.xml
  def create
    @shopping_payment = Shopping::Payment.new(params[:shopping_payment])

    respond_to do |format|
      if @shopping_payment.save
        format.html { redirect_to(@shopping_payment, :notice => 'Payment was successfully created.') }
        format.xml  { render :xml => @shopping_payment, :status => :created, :location => @shopping_payment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shopping_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shopping/payments/1
  # PUT /shopping/payments/1.xml
  def update
    @shopping_payment = Shopping::Payment.find(params[:id])

    respond_to do |format|
      if @shopping_payment.update_attributes(params[:shopping_payment])
        format.html { redirect_to(@shopping_payment, :notice => 'Payment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shopping_payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shopping/payments/1
  # DELETE /shopping/payments/1.xml
  def destroy
    @shopping_payment = Shopping::Payment.find(params[:id])
    @shopping_payment.destroy

    respond_to do |format|
      format.html { redirect_to(shopping_payments_url) }
      format.xml  { head :ok }
    end
  end
end
