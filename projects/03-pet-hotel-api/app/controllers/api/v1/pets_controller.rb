module Api
  module V1
    class PetsController < ApplicationController
      before_action :set_pet, only: %i[show update destroy]

      def index
        pets = current_user.pets.includes(:owner).order(:name)
        render json: pets.map { |pet| pet_payload(pet) }
      end

      def show
        render json: pet_payload(@pet)
      end

      def create
        pet = current_user.pets.new(pet_params)

        if pet.save
          render json: pet_payload(pet),
                 status: :created,
                 location: api_v1_pet_url(pet)
        else
          render_errors(pet)
        end
      end

      def update
        if @pet.update(pet_params)
          render json: pet_payload(@pet)
        else
          render_errors(@pet)
        end
      end

      def destroy
        @pet.destroy
        head :no_content
      end

      private

      def set_pet
        @pet = current_user.pets.includes(:owner).find(params[:id])
      end

      def pet_params
        params.require(:pet).permit(:name, :species, :owner_id)
      end
    end
  end
end
