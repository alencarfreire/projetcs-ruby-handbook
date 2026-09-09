class Pet < ApplicationRecord
  belongs_to :user
  belongs_to :owner
  has_many :stays, dependent: :destroy

  validates :name, presence: true
  validates :species, presence: true
  validate :owner_belongs_to_same_user

  private

  def owner_belongs_to_same_user
    return if owner.blank? || user.blank?
    return if owner.user_id == user_id

    errors.add(:owner, "deve pertencer ao mesmo usuário")
  end
end
