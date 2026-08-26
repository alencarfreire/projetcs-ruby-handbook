class Stay < ApplicationRecord
  # enum: inteiro no SQLite, predicados no Ruby (scheduled?, checked_in?).
  enum :status, { scheduled: 0, checked_in: 1, checked_out: 2 }

  belongs_to :user
  belongs_to :pet
  has_one :owner, through: :pet

  validates :check_in, presence: true
  validates :check_out, presence: true
  validates :nightly_rate_cents, presence: true,
                                 numericality: { only_integer: true, greater_than: 0 }
  validate :check_out_after_check_in
  validate :minimum_one_night
  validate :only_one_checked_in_stay_per_pet
  validate :pet_belongs_to_same_user

  # Diárias em dias corridos. Integer, nunca Float.
  def nights
    return 0 if check_in.blank? || check_out.blank?

    (check_out.to_date - check_in.to_date).to_i
  end

  # total_cents = nights * nightly_rate_cents. Sempre integer (centavos).
  def total_cents
    nights * nightly_rate_cents.to_i
  end

  private

  def check_out_after_check_in
    return if check_in.blank? || check_out.blank?
    return if check_out > check_in

    errors.add(:check_out, "deve ser depois do check-in")
  end

  def minimum_one_night
    return if check_in.blank? || check_out.blank?
    return if nights >= 1

    errors.add(:base, "a hospedagem precisa ter no mínimo 1 diária")
  end

  # Um pet só tem UMA stay checked_in por vez — regra no model, não só na view.
  def only_one_checked_in_stay_per_pet
    return unless checked_in?
    return if pet_id.blank?

    clash = Stay.where(pet_id: pet_id, status: :checked_in)
    clash = clash.where.not(id: id) if persisted?
    return unless clash.exists?

    errors.add(:pet, "já está hospedado — só uma stay checked_in por vez")
  end

  def pet_belongs_to_same_user
    return if pet.blank? || user.blank?
    return if pet.user_id == user_id

    errors.add(:pet, "deve pertencer ao mesmo usuário")
  end
end
