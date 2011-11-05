class Admin::Document::InvoicesController < Admin::BaseController
  include InvoicePrinter

  def index
    params[:page] ||= 1
    params[:rows] ||= 25
    @invoices = Invoice.includes([:order]).
                        paginate({:page => params[:page].to_i,:per_page => params[:rows].to_i})
  end

  def show
    @invoice = Invoice.includes([:order => [
                                            :bill_address,
                                            :ship_address
                                            ]]).find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        #prawnto :prawn=>{:skip_page_creation=>true}
        send_data print_form(@invoice).render, :filename => "invoice_#{@invoice.number}.pdf", :type => 'application/pdf'
      end
    end
  end

  def destroy
    @invoice = Invoice.includes([:order]).find(params[:id])
    @invoice.cancel_authorized_payment
    redirect_to admin_document_invoices_url
  end

  private

  def form_info

  end
end
