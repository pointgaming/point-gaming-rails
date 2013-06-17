module Features
  module JavascriptHelpers

    def hover_over_jquery_selector(jquery_selector)
      page.execute_script("$('#{jquery_selector}').trigger('mouseover')")
    end

  end
end
