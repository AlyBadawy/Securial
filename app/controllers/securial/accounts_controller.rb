module Securial
  class AccountsController < ApplicationController
    def me
      @securial_user = Current.user

      render :show, status: :ok, location: @securial_user
    end

    def show
      @securial_user = User.find_by(username: params.expect(:username))
      render_user_profile
    end

    def register
      @securial_user = User.new(user_params)
      if @securial_user.save
        render :show, status: :created, location: @securial_user
      else
        render json: { errors: @securial_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_profile
      @securial_user = Current.user
      if @securial_user.authenticate(params[:securial_user][:current_password])
        if @securial_user.update(user_params)
          render :show, status: :ok, location: @securial_user
        else
          render json: { errors: @securial_user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
      end
    end

    def delete_account
      @securial_user = Current.user
      if @securial_user.authenticate(params.expect(securial_user: [:current_password]).dig(:current_password))
        @securial_user.destroy
        render json: { message: "Account deleted successfully" }, status: :ok
      else
        render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.expect(securial_user: [:email_address, :password, :password_confirmation, :first_name, :last_name, :phone, :username, :bio])
    end

    def render_user_profile
      if @securial_user
        render :show, status: :ok, location: @securial_user
      else
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end
