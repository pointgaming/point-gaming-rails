class User
  include Mongoid::Document
  include Rails.application.routes.url_helpers
  include Mongoid::Paperclip
  include Tire::Model::Search
  include Tire::Model::Callbacks

  has_mongoid_attached_file :avatar, :default_url => "/system/:class/:attachment/missing_:style.png", styles: {thumb: '50x50', medium: '200'}

  before_validation :populate_slug

  before_create :create_forum_user
  before_create :create_store_user
  before_update :update_forum_user
  before_update :update_store_user
  after_destroy :destroy_forum_user
  after_destroy :destroy_store_user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :multi_token_authenticatable, :recoverable, 
         :rememberable, :trackable, :validatable

  field :_id, :type => String, :default => proc{ UUIDTools::UUID.random_create.to_s }

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :username
  field :slug, :type => String, :default => ''
  field :first_name
  field :last_name
  field :time_zone, default: Rails.application.config.time_zone
  field :birth_date, type: Date
  field :phone
  field :country
  field :state
  field :points, type: Integer, default: 0
  field :stream_owner_count, :type => Integer, :default => 0
  field :admin, :type => Boolean, :default => 0
  field :stripe_customer_token

  # online/offline chat status
  field :status

  attr_accessible :username, :first_name, :last_name, :email, :password, :password_confirmation, 
                  :remember_me, :status, :birth_date, :age, :phone, :profile_attributes, 
                  :avatar, :country, :state, :game

  validates_presence_of :username, :slug, :first_name, :last_name
  validates_uniqueness_of :username, :slug, :email, :case_sensitive => false

  validates :username, :format => {:with => APP_CONFIG[:display_name_regex], message: APP_CONFIG[:display_name_regex_message]}

  belongs_to :profile

  belongs_to :game

  belongs_to :team

  belongs_to :group

  has_many :auth_tokens, :validate=>false
  has_many :coins, :validate=>false
  has_many :friends, :validate=>false
  has_many :blocked_users, :validate=>false
  has_many :configs, class_name: 'UserConfig'

  accepts_nested_attributes_for :profile

  def age
    return "" unless birth_date?

    today = Date.today
    age = today.year - birth_date.year
    age -= 1 if birth_date.yday > Date.today.yday
    age
  end

  def to_param
    self.slug
  end

  def profile_url
    user_url(self)
  end

  def as_json(options={})
    super({
      methods: [:profile_url, :age]
    }.merge(options))
  end

  def display_name
    username
  end

  def has_stripe_token?
    self.stripe_customer_token.present?
  end

  def stream_limit
    50
  end

  def blocked_user?(user)
    BlockedUser.where(user_id: self._id, blocked_user_id: user._id).exists?
  end

  def friend_request_sent?(user)
    FriendRequest.where(user_id: id, friend_request_user_id: user.id).exists?
  end

  def friends_with?(user)
    Friend.where(user_id: id, friend_user_id: user.id).exists? &&
      Friend.where(user_id: user.id, friend_user_id: id).exists?
  end

  def store_sort
    90
  end

  def main_sort
    0
  end

  def forum_sort
    90
  end

  settings analysis: {
      analyzer: {
        partial_match: {
          tokenizer: :whitespace,
          filter: [:lowercase, :edge_ngram]
        }
      },
      filter: {
        edge_ngram: {
            side: :front,
            max_gram: 20,
            min_gram: 1,
            type: :edgeNGram
        }
      }
    } do
    mapping do
      indexes :display_name, type: 'string', boost: 10, analyzer: 'snowball', as: 'username'
      indexes :prefix, type: 'string', index_analyzer: 'partial_match', search_analyzer: 'snowball', boost: 2, as: 'username'
      indexes :url, type: 'string', :index => 'no', as: 'profile_url'

      indexes :store_sort, type: 'short', :index => 'not_analyzed', as: 'store_sort'
      indexes :main_sort, type: 'short', :index => 'not_analyzed', as: 'main_sort'
      indexes :forum_sort, type: 'short', :index => 'not_analyzed', as: 'forum_sort'
    end
  end

protected

  def populate_slug
    self.slug = username.downcase.gsub(/\s/, "_") if username.present?
    true
  end

  def create_forum_user
    forum_user = ForumUser.new :email => self.email, :username => self.username, :admin => self.admin, avatar_thumb_url: self.avatar.url(:thumb)
    if forum_user.save
      true
    else
      self.errors[:base] << "Failed to create your form account."
      false
    end
  end

  def update_forum_user
    if self.email_changed? || self.username_changed? || self.admin_changed? || self.avatar_updated_at_changed?
      forum_user = ForumUser.find self.email_was
      forum_user.email = self.email
      forum_user.username = self.username
      forum_user.admin = self.admin
      forum_user.avatar_thumb_url = self.avatar.url(:thumb)
      if forum_user.save
        true
      else
        self.errors[:base] << "Failed to update your forum account."
        false
      end
    end
  end

  def destroy_forum_user
    begin
      forum_user = ForumUser.find self.email
      forum_user.destroy
    rescue ActiveResource::ResourceNotFound
      # forumUser was not found
    end
  end

  def create_store_user
    store_user = Store::User.new :email => self.email, :username => self.username, :admin => self.admin
    if store_user.save
      true
    else
      self.errors[:base] << "Failed to create your store account."
      false
    end
  end

  def update_store_user
    if self.email_changed? || self.username_changed? || self.admin_changed?
      store_user = Store::User.find self.email_was
      store_user.email = self.email
      store_user.username = self.username
      store_user.admin = self.admin
      if store_user.save
        true
      else
        self.errors[:base] << "Failed to update your store account."
        false
      end
    end
  end

  def destroy_store_user
    begin
      store_user = Store::User.find self.email
      store_user.destroy
    rescue ActiveResource::ResourceNotFound
      # StoreUser was not found
    end
  end

end
