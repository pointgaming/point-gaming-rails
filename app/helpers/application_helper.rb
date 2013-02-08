module ApplicationHelper
    def navItem(link_text, link_path, html_options = {})
        class_name = current_page?(link_path) ? 'active' : ''

        content_tag(:li, :class => class_name) do
            link_to link_text, link_path
        end
    end

    def store_path
      APP_CONFIG['store_url']
    end
end
