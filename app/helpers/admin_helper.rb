module AdminHelper
  def error_msgs_for(obj)
    if obj.errors.any?
      s = ''
      obj.errors.full_messages.each do |msg|
        s << render(:partial => "admin/flash_form_error_template", :locals => { :msg => msg})
      end 
      s.html_safe
    end 
  end 
end
