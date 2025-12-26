module Securial
  #
  # RoleAssignmentsController
  #
  # Controller for managing role assignments in the Securial authorization system.
  #
  # This controller handles role management operations including:
  #   - Assigning roles to users
  #   - Removing roles from users
  #
  # All operations require admin authentication and are typically used for
  # user permission management within the application.
  #
  # Routes typically mounted at Securial/admins/role_assignments/* in the host application.
  #
  class RoleAssignmentsController < ApplicationController
    # Assigns a role to a user.
    #
    # Creates a new role assignment between the specified user and role.
    # Validates that the assignment doesn't already exist.
    #
    # @param [Integer] params[:user_id] The ID of the user to assign the role to
    # @param [Integer] params[:role_id] The ID of the role to be assigned
    # @return [void] Renders the created assignment with 201 Created status or errors with 422
    def create
      return unless define_user_and_role

      if @securial_user.roles.exists?(@securial_role.id)
        render json: {
          errors: ["Role already assigned to user"],
          instructions: "Please check the user's current roles before assigning a new one.",
          }, status: :unprocessable_content
        return
      end
      @securial_role_assignment = RoleAssignment.new(securial_role_assignment_params)
      @securial_role_assignment.save
      render :show, status: :created
    end

    # Removes a role from a user.
    #
    # Deletes an existing role assignment between the specified user and role.
    # Validates that the assignment exists before attempting deletion.
    #
    # @param [Integer] params[:user_id] The ID of the user to remove the role from
    # @param [Integer] params[:role_id] The ID of the role to be removed
    # @return [void] Renders the deleted assignment with 200 OK status or errors with 422
    def destroy
      return unless define_user_and_role
      @role_assignment = RoleAssignment.find_by(securial_role_assignment_params)
      if @role_assignment
        @role_assignment.destroy!
        render :show, status: :ok
      else
        render json: {
          errors: ["Role is not assigned to user"],
          instructions: "Please check the user's current roles before attempting to remove a role.",
          }, status: :unprocessable_content
      end
    end

    private

    # Looks up and validates the existence of both the user and role.
    #
    # Sets @securial_user and @securial_role instance variables if both exist.
    # Renders error responses if either cannot be found.
    #
    # @return [Boolean] true if both user and role were found, false otherwise
    def define_user_and_role
      @securial_user = User.find_by(id: params.expect(securial_role_assignment: [:user_id]).dig(:user_id))
      @securial_role = Role.find_by(id: params.expect(securial_role_assignment: [:role_id]).dig(:role_id))
      if @securial_user.nil?
        render json: {
          errors: ["User not found"],
          instructions: "Please check the user ID and try again.",
          }, status: :unprocessable_content
        return false
      end
      if @securial_role.nil?
        render json: {
          errors: ["Role not found"],
          instructions: "Please check the role ID and try again.",
        }, status: :unprocessable_content
        return false
      end

      true
    end

    # Permits and extracts role assignment parameters from the request.
    #
    # @return [ActionController::Parameters] Permitted role assignment parameters
    def securial_role_assignment_params
      params.expect(securial_role_assignment: [:user_id, :role_id])
    end
  end
end
