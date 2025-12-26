module Securial
  #
  # AccountsController
  #
  # This controller handles user account-related operations including:
  #   - User registration
  #   - Profile viewing and management
  #   - Account updates
  #   - Account deletion
  #
  # Routes typically mounted at Securial/accounts/* in the host application.
  #
  class AccountsController < ApplicationController
    # Retrieves the current user's profile.
    #
    # Provides the authenticated user's complete profile information.
    # Requires authentication via the Identity concern.
    #
    # @return [void] Renders user profile with 200 OK status
    def me
      @securial_user = Current.user

      render :show, status: :ok, location: @securial_user
    end

    # Shows a specific user's profile by username.
    #
    # Retrieves and displays public profile information for the requested user.
    # Requires the `enable_other_profiles` configuration to be true.
    #
    # @param [String] params[:username] The username of the requested user profile
    # @return [void] Renders user profile with 200 OK status or 404 if not found
    def show
      if Securial.configuration.enable_other_profiles
        @securial_user = Securial::User.find_by(username: params.expect(:username))
        render_user_profile
      else
        render json: {
          errors: ["User profiles are not enabled"],
          instructions: "Please contact support for assistance.",
        }, status: :forbidden
      end
    end

    # Registers a new user account.
    #
    # Creates a new user in the system with the provided registration information.
    #
    # @param [Hash] params[:securial_user] User attributes including email_address, password, etc.
    # @return [void] Renders new user with 201 Created status or errors with 422
    def register
      @securial_user = Securial::User.new(user_params)
      if @securial_user.save
        render :show, status: :created, location: @securial_user
      else
        render json: {
          errors: @securial_user.errors.full_messages }, status: :unprocessable_content
      end
    end

    # Updates the current user's profile information.
    #
    # Allows users to modify their profile after authenticating with their current password.
    #
    # @param [String] current_password User's current password for verification
    # @param [Hash] params[:securial_user] Updated user attributes
    # @return [void] Renders updated user with 200 OK status or errors with 422
    def update_profile
      @securial_user = Current.user
      if @securial_user.authenticate(params[:securial_user][:current_password])
        if @securial_user.update(user_params)
          render :show, status: :ok, location: @securial_user
        else
          render json: {
            errors: @securial_user.errors.full_messages,
            instructions: "Please ensure all required fields are filled out correctly.",
            }, status: :unprocessable_content
        end
      else
        render json: {
          errors: ["Current password is incorrect"],
          instructions: "Please verify your current password and try again.",
          }, status: :unprocessable_content
      end
    end

    # Permanently deletes the current user's account.
    #
    # Removes the user account and all associated data after password verification.
    #
    # @param [String] params[:current_password] User's current password for verification
    # @return [void] Renders success message with 200 OK status or error with 422
    def delete_account
      @securial_user = Current.user
      if @securial_user.authenticate(params.expect(securial_user: [:current_password]).dig(:current_password))
        @securial_user.destroy
        render json: { message: "Account deleted successfully" }, status: :ok
      else
        render json: {
          errors: ["Current password is incorrect"],
          instructions: "Please verify your current password and try again.",
        }, status: :unprocessable_content
      end
    end

    private

    # Permits and extracts user parameters from the request.
    #
    # @return [ActionController::Parameters] Permitted user parameters
    #
    def user_params
      params.expect(securial_user: [:email_address, :password, :password_confirmation, :first_name, :last_name, :phone, :username, :bio])
    end

    # Renders the user profile or a not found response.
    #
    # @return [void] Renders user profile or not found error
    #
    def render_user_profile
      if @securial_user
        render :show, status: :ok, location: @securial_user
      else
        render json: {
          errors: ["User not found"],
          instructions: "Please check the username and try again.",
        }, status: :not_found
      end
    end
  end
end
