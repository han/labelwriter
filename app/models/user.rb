class User < ActiveRecord::Base

  ROLES = ['extern', 'pls', 'admin']

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable 

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  validates :password, :confirmation => true
  validates :email, :uniqueness => true
  validates :email, :presence => true
  validates :email, :format => {:with => Devise.email_regexp}
  validates :role, :inclusion => {:in => ROLES}

  before_validation :random_password, :on => :create

  def admin?
    self.role == 'admin'
  end

  def extern?
    self.role == 'extern'
  end

  def active?
    self.status == 'active'
  end

  def delete!
    self.status = 'deleted'
    save
  end

  private

  def random_password
    if password.nil?
      self.password = ActiveSupport::SecureRandom.base64(12).tr('+/=', 'xyz')
      self.password_confirmation = self.password
    end
  end

end
