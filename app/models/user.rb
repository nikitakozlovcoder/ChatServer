class User < ApplicationRecord
  has_secure_password(validations: false)
  has_many :messages
  has_many :rooms_user
  has_many :rooms, through: :rooms_user
  accepts_nested_attributes_for :rooms_user
  attr_accessor :register, :mail_confirmation, :login

  validates :name, length: {in: 4..30, :message => :length}, :unless => Proc.new { |user| user.login  }
  validates :password_confirmation, presence: {:message => :presence}, :if => Proc.new { |user| user.register  }
  validates :password, confirmation: {message: :confirmation}, presence: {message: :presence}, :if => Proc.new { |user| user.register  }
  validates :password, confirmation: {message: :confirmation}, presence: {message: :presence}, :if => Proc.new { |user| user.login  }
  validates :mail, uniqueness: {message: "Mail should be unique"},:unless => Proc.new { |user| user.login  }
  validates :mail, confirmation: {message: "Mail does not math"}, presence: {message: "Mail should be entered"}, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Mail should be valid" }
  validates :mail_confirmation, presence: {:message => "Mail Confirmation should be filled"}, :if => Proc.new { |user| user.register  }
 # validates :mail, presence: {message: "Mail should be entered"}
 # validate :check_email

 # def check_email
  #  errors.add(:mail_confirmation, "Test message") if mail != mail_confirmation
 # end
  def self.register(args)
    user = User.new(args.require(:user).permit(:name, :mail))
    user.password = args[:user][:password]
    user.password_confirmation = args[:user][:password_confirmation]
    user.mail_confirmation = args[:user][:mail_confirmation]
    user.register = true
    user.save
    return user
  end

  def gen_token
    payload = { data: self.id }
   # logger.debug Rails.application.credentials.secret_key_base
    JWT.encode payload, Rails.application.credentials.secret_key_base , 'HS256'
  end

  def self.get_id_from_token(token)
    begin
      arr = JWT.decode token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' }
      return arr[0]["data"]
    rescue JWT::VerificationError
      return -1
    rescue JWT::DecodeError
      return -1
    end
  end

  def auth(password)
    if self.authenticate(password)
     return true
    end
    return false
  end
end
