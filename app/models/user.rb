class User < ActiveRecord::Base

  before_save :downcase_email
  attr_accessor :remember_token, :activation_token
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  has_many :grades
  has_many :courses, through: :grades

  has_many :teaching_courses, class_name: "Course", foreign_key: :teacher_id

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  #1. The ability to save a securely hashed password_digest attribute to the database
  #2. A pair of virtual attributes (password and password_confirmation), including presence validations upon object creation and a validation requiring that they match
  #3. An authenticate method that returns the user when the password is correct (and false otherwise)
  has_secure_password
  # has_secure_password automatically adds an authenticate method to the corresponding model objects.
  # This method determines if a given password is valid for a particular user by computing its digest and comparing the result to password_digest in the database.

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def user_remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def user_forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given token matches the digest.
  def user_authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
   
    return false if digest.nil?
    obj=BCrypt::Password.new(digest)
    puts "Bcrypt::passoword"
    puts obj.to_s
    obj.is_password?(token)
  end
  
  # def validate
  #   #验证name不能为空
  #   errors.add("", "用户只能是字母、数字或者下划线，且长度必须为4到20位")
  #     unless name = ~/^\w{4,20}$/
  #   end
  #   #验证name不能是数据库中已经存在的名字
  #   errors.add("", "用户名不能重复，您选择的用户已经存在")
  #     unless User.find_by_name(name).nil?
  #   end
  #   #验证password不能为空
  #   errors.add("", "密码只能是字母、数字或者下划线，且长度必须为4到20位")
  #     unless password = ~/^[a-zA-Z0-9]{4,20}$/
  #   end
  #   #验证email的规则
  #   errors.add("", "电子邮件必须匹配电子邮件规则")
  #     unless email = ~/^\w+@\w+,[a-zA-Z]{2,6}$/
  #   end
  # end
  
  #创建并赋值激活令牌和摘要
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
     puts "digest"
    puts digest
    return false if digest.nil?
    obj=BCrypt::Password.new(digest)
    puts "Bcrypt::passoword"
    puts obj.to_s
    obj.is_password?(token)
    return true
  end
  
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  private

  def downcase_email
    self.email = email.downcase
  end
end
