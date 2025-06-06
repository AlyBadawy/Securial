class SeedRolesAndUsers < ActiveRecord::Migration[8.0]
  def up
    default_email = "user@example.com"
    default_password = "Password123!"

    default_admin_role = Securial.configuration.admin_role

    # Create a default user (no roles assigned)
    Securial::User.find_or_create_by!(email_address: default_email) do |user|
      user.password = default_password
      user.password_confirmation = default_password
      user.username = "default_user"
      user.first_name = "Default"
      user.last_name = "User"
    end
    Securial.logger.debug "Created user: #{default_email} with password: #{default_password}"

    # Default roles
    roles = %w[admin moderator support locked]
    roles << default_admin_role
    roles.uniq!

    roles.each do |role_name|
      # Create roles if they do not exist
      Securial::Role.find_or_create_by!(role_name: role_name)
      Securial.logger.debug "Created role: #{role_name}"

      # Create a user for each role
      user = Securial::User.find_or_create_by!(email_address: "#{role_name}@example.com") do |u|
        u.password = "Password123!"
        u.password_confirmation = "Password123!"
        u.username = role_name
        u.first_name = role_name.capitalize
        u.last_name = "User"
      end

      Securial.logger.debug "Created user: #{user.email_address} with password: #{default_password}"

      # Assign the role to the user
      user.roles = Securial::Role.where(role_name: role_name)
      Securial.logger.debug "Assigned role: #{role_name} to user: #{user.email_address}"
      user.save!
    end
  end

  def down
    default_admin_role = Securial.configuration.admin_role
    roles = %w[admin moderator support locked]
    roles << default_admin_role
    roles.uniq!

    # Remove role-specific users
    roles.each do |role_name|
      user = Securial::User.find_by(email_address: "#{role_name}@example.com")
      user.destroy if user
      Securial.logger.debug "Removed user: #{role_name}@example.com"
    end

    # Remove the default user with no roles
    user = Securial::User.find_by(email_address: "user@example.com")
    user.destroy if user
    Securial.logger.debug "Removed user: user@example.com"


    # Remove the roles themselves
    Securial::Role.where(role_name: roles).destroy_all
    Securial.logger.debug "Removed roles: #{roles.join(', ')}"
  end
end
