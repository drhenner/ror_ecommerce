module ApplicationHelper
  
  ### The next three helpers are great to use to add and remove nested attributes in forms.
  #  LOK AT THIS WEBPAGE FOR REFERENCE
  ## http://openmonkey.com/articles/2009/10/complex-nested-forms-with-rails-unobtrusive-jquery
=begin
EXAMPLE USAGE!!
  <% form.fields_for :properties do |property_form| %>
    <%= render :partial => '/admin/merchandise/add_property', :locals => { :f => property_form } %>
  <% end %>
  <p><%= add_child_link "New Property", :properties %></p>
  <%= new_child_fields_template(form, :properties, :partial => '/admin/merchandise/add_property')%>
=end  
  def remove_child_link(name, f)
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", :class => "remove_child")
  end
  
  def add_child_link(name, association)
    link_to(name, "javascript:void(0);", :class => "add_child", :"data-association" => association)
  end
  
  def new_child_fields_template(form_builder, association, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize
    options[:form_builder_local] ||= :f
    
    content_tag(:div, :id => "#{association}_fields_template", :style => "display: none") do
      form_builder.fields_for(association, options[:object], :child_index => "new_#{association}") do |f|
        render(:partial => options[:partial], :locals => {options[:form_builder_local] => f})
      end
    end
  end
  
  ####
  def fieldset_container(model, method, options = {}, &block)
    unless error_message_on(model, method).blank?
      options[:class] ||= ''
      options[:class] = options[:class] + ' fieldWithErrors'
    end
    html = content_tag('fieldset', capture(&block), options)
    concat(html)
  end
  
  ##############################################################################
  # Overrides submit_tag for disable save after click event  --
  ##############################################################################
  def commit_tag(value,options={})
    options.stringify_keys!
    submit_tag value, options.merge(:onclick => '

     if(window.addEventListener)
     {
       this.disabled = true;
     }
     else
     { // IE
       var element = window.event.srcElement;
       var  tag = element.tagName.toLowerCase();
      if(tag == "input")
       {
         var click = element.onclick;
         var keypress = element.onkeypress;
         setTimeout(function() { element.disabled = true; element.onclick = null; element.onkeypress = null; }, 0);
         setTimeout(function() { element.disabled = false; element.onclick = click; element.onkeypress =keypress; }, 50000);
       }
     }
     ')
  end
end
