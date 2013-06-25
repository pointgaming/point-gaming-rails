module ApplicationHelper
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

    def time_zone_offset(time_zone)
      ActiveSupport::TimeZone.new(time_zone || "Central Time (US & Canada)").now.formatted_offset
    end

    def ldate(dt, options = {})
      dt ? l(dt, options) : ''
    end

    def forum_path
      APP_CONFIG['forum_url']
    end

    def store_path
      APP_CONFIG['store_url']
    end

    def admin_path
      APP_CONFIG['admin_url']
    end

    def devise_mapping
      @devise_mapping ||= Devise.mappings[:user]
    end

    # Creates a link tag to a given url or path and ensures that the linke will be rendered
    # as jquery modal dialog
    #
    # ==== Signatures
    #
    #   link_to(body, url, html_options = {})
    #   link_to(body, url)
    #
    def link_to_modal(*args, &block)
      if block_given?
        options      = args.first || {}
        html_options = args.second
        block_result = capture(&block)
        link_to_modal(block_result, options, html_options)
      else
        name         = args[0]
        options      = args[1] || {}
        html_options = args[2] || {}

        # extend the html_options
        html_options[:rel] = "modal:open"
        if (html_options.has_key?(:remote))
          if (html_options[:remote] == true)
            html_options[:rel] = "modal:open:ajaxpost"
          end

          # remove the remote tag
          html_options.delete(:remote)
        end

        # check if we have an id
        html_options[:id] = UUIDTools::UUID.random_create().to_s unless html_options.has_key?(:id)

        # perform the normal link_to operation
        html_link = link_to(name, options, html_options)

        # emit both
        html_link.html_safe
      end
    end
end
