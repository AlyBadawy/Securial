module Securial
  #
  # UsersController
  #
  # Controller for managing users in the Securial authentication system.
  #
  # This controller provides administrative CRUD operations for user management, including:
  #   - Listing all users in the system
  #   - Creating new user accounts
  #   - Viewing user details
  #   - Updating user information
  #   - Deleting user accounts
  #
  # All operations require admin authentication and are typically used for
  # administrative user management rather than self-service account management.
  #
  # Routes typically mounted at Securial/admins/users/* in the host application.
  #
  class UsersController < ApplicationController
    before_action :set_securial_user, only: [:show, :update, :destroy]

    # Lists all users in the system.
    #
    # Retrieves all users for administrative display and management.
    #
    # @return [void] Renders index view with all users
    def index
      @securial_users = User.all
    end

    # Shows details for a specific user.
    #
    # Retrieves and displays information for a single user.
    #
    # @param [Integer] params[:id] The ID of the user to display
    # @return [void] Renders show view with the specified user
    def show
    end

    # Creates a new user in the system.
    #
    # Adds a new user with the provided attributes.
    #
    # @param [Hash] params[:securial_user] User attributes including email_address, username, etc.
    # @return [void] Renders the created user with 201 Created status or errors with 422
    def create
      @securial_user = User.new(securial_user_params)

      if @securial_user.save
        render :show, status: :created, location: @securial_user
      else
        render json: @securial_user.errors, status: :unprocessable_content
      end
    end

    # Updates an existing user.
    #
    # Modifies the attributes of an existing user.
    #
    # @param [Integer] params[:id] The ID of the user to update
    # @param [Hash] params[:securial_user] Updated user attributes
    # @return [void] Renders the updated user or errors with 422 status
    def update
      if @securial_user.update(securial_user_params)
        render :show, status: :ok, location: @securial_user
      else
        render json: @securial_user.errors, status: :unprocessable_content
      end
    end

    # Deletes an existing user.
    #
    # Permanently removes a user from the system.
    #
    # @param [Integer] params[:id] The ID of the user to delete
    # @return [void] Returns 204 No Content status
    def destroy
      @securial_user.destroy
      head :no_content
    end

    private

    # Finds and sets a specific user for show, update and destroy actions.
    #
    # @return [void]
    #
    def set_securial_user
      @securial_user = User.find(params[:id])
    end

    # Permits and extracts user parameters from the request.
    #
    # @return [ActionController::Parameters] Permitted user parameters
    def securial_user_params
      params.expect(securial_user: [
                      :email_address,
                      :username,
                      :first_name,
                      :last_name,
                      :phone,
                      :bio,
                      :password,
                      :password_confirmation,
        ])
    end
  end
end
