module NavigationHelper

  def navItem(link_text, link_path, options = {})
    is_current_page = if options[:exact] === true
      current_page_exact?(link_path)
    else
      current_page?(link_path)
    end

    class_name = options[:class].present? ? options[:class] : ""
    class_name = "#{class_name} #{is_current_page ? 'active' : ''}"

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def current_page_exact?(options)
    unless request
      raise "You cannot use helpers that need to determine the current " \
            "page unless your view context provides a Request object " \
            "in a #request method"
    end

    return false unless request.get?

    url_string = url_for(options)
    request_uri = request.fullpath

    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
    else
      url_string == request_uri
    end
  end

end
