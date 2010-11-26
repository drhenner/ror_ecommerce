require 'prawnto'

Mime::Type.register "application/pdf", :pdf
ActionView::Template.register_template_handler 'prawn', Prawnto::TemplateHandlers::Base
ActionView::Template.register_template_handler 'prawn_dsl', Prawnto::TemplateHandlers::Dsl
ActionView::Template.register_template_handler 'prawn_xxx', Prawnto::TemplateHandlers::Raw

# Bit of a hack to enable ActionMailer to us pdf.prawn templates to generate attachments
if defined?(ActionMailer) && defined?(ActionMailer::Base)
  ActionMailer::Base.send(:include, Prawnto::ActionController)
end
