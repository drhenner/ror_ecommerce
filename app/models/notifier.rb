class Notifier < ActionMailer::Base
  default :from => "system@example.com"
  
  def signup_notification(recipient)
    @account = recipient

    #attachments['an-image.jp'] = File.read("an-image.jpg")
    #attachments['terms.pdf'] = {:content => generate_your_pdf_here() }

    mail(:to => recipient.email_address_with_name,
         :subject => "New account information") do |format|
      format.text { render :text => "Welcome!  #{recipient.name}" }
      format.html { render :text => "<h1>Welcome</h1> #{recipient.name}" }
    end
         
  end
end
