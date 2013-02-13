class User
  include Mongoid::Document

  before_create :create_store_user
  before_update :update_store_user
  after_destroy :destroy_store_user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, 
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
  field :first_name
  field :last_name
  field :points, type: Integer, default: 0

  # online/offline chat status
  field :status

  attr_accessible :username, :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :status

  validates_presence_of :username, :first_name, :last_name
  validates_uniqueness_of :username, :email, :case_sensitive => false

  has_many :auth_tokens, :validate=>false
  has_many :coins, :validate=>false
  has_many :friends, :validate=>false
  has_many :ignores, :validate=>false

protected

  def create_store_user
    store_user = StoreUser.new :email => self.email
    if store_user.save
      true
    else
      self.errors[:base] << "Failed to create your form account."
      false
    end
  end

  def update_store_user
    if self.email_changed?
      store_user = StoreUser.find self.email_was
      store_user.email = self.email
      if store_user.save
        true
      else
        self.errors[:base] << "Failed to update your form account."
        false
      end
    end
  end

  def destroy_store_user
    begin
      store_user = StoreUser.find self.email
      store_user.destroy
    rescue ActiveResource::ResourceNotFound
      # StoreUser was not found
    end
  end
end
