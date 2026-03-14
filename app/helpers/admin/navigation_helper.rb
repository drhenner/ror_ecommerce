module Admin::NavigationHelper
  def admin_nav_item(label, path, icon: nil, badge: nil)
    active = request.path.start_with?(path)
    content_tag(:a, href: path, class: "nav-item #{'active' if active}") do
      parts = []
      parts << content_tag(:span, icon, class: "nav-item-icon") if icon
      parts << content_tag(:span, label, class: "nav-item-label")
      parts << content_tag(:span, badge, class: "badge") if badge
      safe_join(parts)
    end
  end

  def admin_nav_group(label, path, icon: nil, badge: nil, &block)
    group_id = label.parameterize
    active = request.path.start_with?(path)

    content_tag(:div, class: "nav-group",
                data: { controller: "nav-group", nav_group_id_value: group_id, nav_group_open_value: active }) do
      trigger = content_tag(:a, class: "nav-item #{'active' if active}",
                            data: { action: "click->nav-group#toggle" }, href: "#") do
        parts = []
        parts << content_tag(:span, icon, class: "nav-item-icon") if icon
        parts << content_tag(:span, label, class: "nav-item-label")
        parts << content_tag(:span, badge, class: "badge") if badge
        parts << content_tag(:span, "\u25B6".html_safe, class: "chevron")
        safe_join(parts)
      end

      children = content_tag(:div, class: "nav-children", data: { nav_group_target: "children" }) do
        capture(&block)
      end

      trigger + children
    end
  end

  def admin_nav_section(label, &block)
    content_tag(:div, class: "nav-section") do
      heading = content_tag(:div, label, class: "nav-section-label")
      heading + capture(&block)
    end
  end

  def admin_user_initials
    return "" unless current_user
    names = current_user.name.to_s.split
    if names.length >= 2
      "#{names.first[0]}#{names.last[0]}".upcase
    else
      current_user.name.to_s[0..1].upcase
    end
  end

  def admin_user_role_label
    if current_user.super_admin?
      "Super Admin"
    elsif current_user.admin?
      "Admin"
    elsif current_user.respond_to?(:warehouse?) && current_user.warehouse?
      "Warehouse"
    elsif current_user.respond_to?(:customer_service?) && current_user.customer_service?
      "Customer Service"
    elsif current_user.respond_to?(:report?) && current_user.report?
      "Reports"
    else
      "Staff"
    end
  end
end
