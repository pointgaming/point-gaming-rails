require 'spec_helper'

feature 'User sponsors are editable' do
  let(:user_sponsor) { Fabricate(:user_sponsor) }
  let(:user) { user_sponsor.user }

  before(:each) { sign_in(user) }

  it "is updated successfully", js: true do
    new_url = 'http://chrisbankston.com'
    new_sponsor = Fabricate.build(:user_sponsor, url: new_url)

    visit edit_user_profile_path(user)

    hover_over_sponsor(user_sponsor)

    within sponsor_container_selector(user_sponsor) do
      click_link 'Edit'
    end

    remove_large_html_chunks

    within('#ajax-modal') do
      fill_in 'Name', with: new_sponsor.name
      fill_in 'Url', with: new_sponsor.url
      attach_file 'Image', File.join(Rails.root, 'spec', 'fabricators', 'images', 'image.jpg')
      fill_in 'Sort order', with: new_sponsor.sort_order
      click_button 'Update Sponsor'
    end

    within sponsor_container_selector(user_sponsor) do
      expect(page).to have_xpath("//a[@href=\"#{new_url}\"]")
    end
  end
end

# hovering over the sponsor container should cause the edit/destroy links to appear
def hover_over_sponsor(sponsor)
  page.execute_script("$('#{sponsor_container_selector(sponsor)}').trigger('mouseover')")
end

def sponsor_container_selector(sponsor)
  "#sponsor_#{user_sponsor._id}"
end

def user_info_fields_container_selector
  "div[data-hook=user_info_fields]"
end

def rig_fields_container_selector
  "div[data-hook=rig_fields]"
end

# This function executes javascript to remove large chunks of html from the page.
# It seems necessary to remove these large html chunks in order to get the tests to pass.
def remove_large_html_chunks
  page.execute_script("$('#{user_info_fields_container_selector}').remove()")
  page.execute_script("$('#{rig_fields_container_selector}').remove()")
end
