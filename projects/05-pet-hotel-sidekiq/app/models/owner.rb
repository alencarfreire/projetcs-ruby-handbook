class Owner < ApplicationRecord
  belongs_to :user
  has_many :pets, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
end
