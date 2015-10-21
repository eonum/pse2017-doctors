class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :imports
  has_many :patient_cases
  has_many :rules
  has_many :categories
  has_many :analyses, class_name: 'Analysis'

  belongs_to :selected_import, class_name: 'Import', index: true
  embeds_many :support_services

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable, :recoverable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :registerable

  before_save :ensure_authentication_token

  ## Database authenticatable
  field :email,              :type => String, :default => ''
  field :encrypted_password, :type => String, :default => ''
  field :disabled_system_categories, :type => Array, :default => []

  validates_presence_of :email
  validates_presence_of :encrypted_password
  
  ## Recoverable
  #field :reset_password_token,   :type => String
  #field :reset_password_sent_at, :type => Time

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
  field :admin, :type => Boolean
  field :expert, :type => Boolean
  field :password
  field :password_confirmation
  field :remember_me
  field :authentication_token
  field :api_access_granted, :type => Boolean

  validates_presence_of :username
  validates_uniqueness_of :username, :email, :case_sensitive => false

  def ensure_authentication_token
    if(self.authentication_token.blank?)
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def self.invalidate_all_authentication_tokens
    User.all.each do |user|
      user.authentication_token = generate_authentication_token
      user.save!
    end
  end

end
