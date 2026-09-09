class OwnersController < ApplicationController
  before_action :set_owner, only: %i[show edit update destroy]

  def index
    @owners = current_user.owners.order(:name)
  end

  def show
  end

  def new
    @owner = current_user.owners.new
  end

  def edit
  end

  def create
    @owner = current_user.owners.new(owner_params)

    if @owner.save
      redirect_to @owner, notice: "Dono cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @owner.update(owner_params)
      redirect_to @owner, notice: "Dono atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @owner.destroy
    redirect_to owners_path, notice: "Dono removido."
  end

  private

  def set_owner
    @owner = current_user.owners.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(:name, :email, :phone)
  end
end
