class User < ApplicationRecord
  attr_reader :password

  validates :email, :password_digest, :session_token, presence: true
  validates :email, uniqueness: true
  validates :password, length: {minimum: 6, allow_nil: true}

  after_initialize :ensure_session_token

  has_many :guest_join_tables,
  foreign_key: :event_id,
  class_name: 'GuestJoinTable'

  has_many :events_attending,
  through: :guest_join_tables,
  source: :event

  has_many :events_hosting,
  foreign_key: :host_id,
  class_name: 'Event'




  def self.find_by_credentials(email, password)
    user = User.find_by(email: email)
    user && user.is_password?(password) ? user : nil
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def reset_session_token!
    self.session_token = SecureRandom.urlsafe_base64
    self.save!
    self.session_token
  end

private

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end


end
