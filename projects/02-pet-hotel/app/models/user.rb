class User < ApplicationRecord
  # has_secure_password (bcrypt): a senha nunca vai para o banco.
  # Só o password_digest. authenticate("senha") compara o hash.
  has_secure_password

  has_many :owners, dependent: :destroy
  has_many :pets, dependent: :destroy
  has_many :stays, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  private

  def normalize_email
    self.email = email.to_s.strip.downcase.presence
  end
end
