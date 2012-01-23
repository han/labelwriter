class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable 

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :admin

  validates :password, :confirmation => true

  before_validation :random_password, :on => :create

  private

  def random_password
    if password.nil?
      self.password = ActiveSupport::SecureRandom.base64(12).tr('+/=', 'xyz')
      self.password_confirmation = self.password
    end
  end

end
