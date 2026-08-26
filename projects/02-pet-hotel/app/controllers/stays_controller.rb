class StaysController < ApplicationController
  before_action :set_stay, only: %i[show edit update destroy check_in check_out]

  def index
    @stays = current_user.stays.includes(:pet, :owner).order(check_in: :desc)
  end

  def show
  end

  def new
    @stay = current_user.stays.new
  end

  def edit
  end

  def create
    @stay = current_user.stays.new(stay_params)

    if @stay.save
      redirect_to @stay, notice: "Hospedagem cadastrada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @stay.update(stay_params)
      redirect_to @stay, notice: "Hospedagem atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stay.destroy
    redirect_to stays_path, notice: "Hospedagem removida."
  end

  def check_in
    if @stay.update(status: :checked_in)
      redirect_to @stay, notice: "Check-in feito."
    else
      redirect_to @stay, alert: @stay.errors.full_messages.to_sentence
    end
  end

  def check_out
    if @stay.update(status: :checked_out)
      redirect_to @stay, notice: "Check-out feito."
    else
      redirect_to @stay, alert: @stay.errors.full_messages.to_sentence
    end
  end

  private

  def set_stay
    @stay = current_user.stays.find(params[:id])
  end

  def stay_params
    params.require(:stay).permit(:pet_id, :check_in, :check_out, :nightly_rate_cents, :status)
  end
end
