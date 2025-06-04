module Securial
  class RoleAssignmentsController < ApplicationController
    def create
      return unless define_user_and_role

      if @securial_user.roles.exists?(@role.id)
        render json: { error: "Role already assigned to user" }, status: :unprocessable_entity
        return
      end
      @securial_role_assignment = RoleAssignment.new(securial_role_assignment_params)
      @securial_role_assignment.save
      render :show, status: :created
    end

    def destroy
      return unless define_user_and_role
      @role_assignment = RoleAssignment.find_by(securial_role_assignment_params)
      if @role_assignment
        @role_assignment.destroy!
        render :show, status: :ok
      else
        render json: { error: "Role is not assigned to user" }, status: :unprocessable_entity
      end
    end

    private

    def define_user_and_role
      @securial_user = User.find_by(id: params.expect(securial_role_assignment: [:user_id]).dig(:user_id))
      @securial_role = Role.find_by(id: params.expect(securial_role_assignment: [:role_id]).dig(:role_id))
      if @securial_user.nil?
        render json: { error: "User not found" }, status: :unprocessable_entity
        return false
      end
      if @securial_role.nil?
        render json: { error: "Role not found" }, status: :unprocessable_entity
        return false
      end

      true
    end

    def securial_role_assignment_params
      params.expect(securial_role_assignment: [:user_id, :role_id])
    end
  end
end
