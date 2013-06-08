module Features
  module FormHelpers

    def select_option(id, value)
      option_xpath = "//*[@id='#{id}']/option[@value='#{value}']"
      option = find(:xpath, option_xpath).text
      select(option, :from => id)
    end

  end
end
