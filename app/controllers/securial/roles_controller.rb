module Securial
  class RolesController < ApplicationController
    before_action :set_securial_role, only: [:show, :update, :destroy]

    def index
      @securial_roles = Role.all
    end

    def show
    end

    def create
      @securial_role = Role.new(securial_role_params)

      if @securial_role.save
        render :show, status: :created, location: @securial_role
      else
        render json: @securial_role.errors, status: :unprocessable_entity
      end
    end

    def update
      if @securial_role.update(securial_role_params)
        render :show
      else
        render json: @securial_role.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @securial_role.destroy
    end

    private

    def set_securial_role
      @securial_role = Role.find(params[:id])
    end

    def securial_role_params
      params.expect(securial_role: [:role_name, :hide_from_profile])
    end
  end
end
