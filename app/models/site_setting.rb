class SiteSetting
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :create_external_site_settings
  before_update :update_external_site_settings
  after_destroy :destroy_external_site_settings

  attr_accessible :value

  field :key, :type => String
  field :value, :type => String

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

private

  def create_external_site_settings
    store_setting = Store::SiteSetting.new :key => self.key, :value => self.value
    forum_setting = ForumSiteSetting.new :key => self.key, :value => self.value
    if store_setting.save && forum_setting.save
      true
    else
      self.errors[:base] << "Failed to sync site setting with external rails apps."
      false
    end
  end

  def update_external_site_settings
    store_setting = Store::SiteSetting.find(key_changed? ? self.key_was : self.key)
    forum_setting = ForumSiteSetting.find(key_changed? ? self.key_was : self.key)

    options = { key: self.key, value: self.value }
    if store_setting.update_attributes(options) && forum_setting.update_attributes(options)
      true
    else
      self.errors[:base] << "Failed to sync site setting with external rails apps."
      false
    end
  end

  def destroy_external_site_setting(klass)
    setting = klass.find(self.key)
    setting.destroy
    # store_setting was not found
  end

  def destroy_external_site_settings
    destroy_external_site_setting(Store::SiteSetting)
    destroy_external_site_setting(ForumSiteSetting)
  end

end
