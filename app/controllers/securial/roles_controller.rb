module Securial
  #
  # RolesController
  #
  # Controller for managing roles in the Securial authorization system.
  #
  # This controller handles role management operations including:
  #   - Creating new roles
  #   - Listing available roles
  #   - Updating role properties
  #   - Deleting roles
  #
  # All operations require admin authentication and are typically used for
  # setting up and managing the application's permission structure.
  #
  # Routes typically mounted at Securial/admins/roles/* in the host application.
  #
  class RolesController < ApplicationController
    before_action :set_securial_role, only: [:show, :update, :destroy]

    # Lists all roles in the system.
    #
    # Retrieves all roles for administrative display and management.
    #
    # @return [void] Renders index view with all roles
    def index
      @securial_roles = Role.all
    end

    # Shows details for a specific role.
    #
    # Retrieves and displays information for a single role.
    #
    # @param [Integer] params[:id] The ID of the role to display
    # @return [void] Renders show view with the specified role
    def show
    end

    # Creates a new role in the system.
    #
    # Adds a new role with the provided attributes.
    #
    # @param [Hash] params[:securial_role] Role attributes including role_name and hide_from_profile
    # @return [void] Renders the created role with 201 Created status or errors with 422
    def create
      @securial_role = Role.new(securial_role_params)

      if @securial_role.save
        render :show, status: :created, location: @securial_role
      else
        render json: @securial_role.errors, status: :unprocessable_content
      end
    end

    # Updates an existing role.
    #
    # Modifies the attributes of an existing role.
    #
    # @param [Integer] params[:id] The ID of the role to update
    # @param [Hash] params[:securial_role] Updated role attributes
    # @return [void] Renders the updated role or errors with 422 status
    def update
      if @securial_role.update(securial_role_params)
        render :show
      else
        render json: @securial_role.errors, status: :unprocessable_content
      end
    end

    # Deletes an existing role.
    #
    # Permanently removes a role from the system.
    #
    # @param [Integer] params[:id] The ID of the role to delete
    # @return [void] Returns 204 No Content status
    def destroy
      @securial_role.destroy
      head :no_content
    end

    private

    # Finds and sets a specific role for show, update and destroy actions.
    #
    # @param [Integer] params[:id] The ID of the role to find
    # @return [void]
    def set_securial_role
      @securial_role = Role.find(params[:id])
    end

    # Permits and extracts role parameters from the request.
    #
    # @return [ActionController::Parameters] Permitted role parameters
    #
    def securial_role_params
      params.expect(securial_role: [:role_name, :hide_from_profile])
    end
  end
end
