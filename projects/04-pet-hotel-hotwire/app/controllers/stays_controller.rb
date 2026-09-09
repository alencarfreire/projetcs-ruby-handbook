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
    change_status(:checked_in, "Check-in feito.")
  end

  def check_out
    change_status(:checked_out, "Check-out feito.")
  end

  private

  def set_stay
    @stay = current_user.stays.find(params[:id])
  end

  def stay_params
    params.require(:stay).permit(:pet_id, :check_in, :check_out, :nightly_rate_cents, :status)
  end

  def change_status(status, success_notice)
    if @stay.update(status: status)
      respond_status_change(notice: success_notice)
    else
      respond_status_change(alert: @stay.errors.full_messages.to_sentence)
    end
  end

  def respond_status_change(notice: nil, alert: nil)
    respond_to do |format|
      format.turbo_stream do
        @stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
        @flash_notice = notice
        @flash_alert = alert
        render :status_change
      end
      format.html do
        redirect_to @stay, notice: notice, alert: alert
      end
    end
  end
end
