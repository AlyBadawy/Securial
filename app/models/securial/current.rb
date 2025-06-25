module Securial
  #
  # Current
  #
  # This class provides a way to access the current session and user
  # throughout the application. It uses ActiveSupport::CurrentAttributes to
  # store the session and delegate the user method to it.
  #
  # It allows you to access the current user in controllers, views, and jobs
  # without having to pass the user object explicitly.
  #
  # Example usage:
  #   Current.session = session
  #   Current.user # => returns the current user object or nil if not authenticated
  class Current < ActiveSupport::CurrentAttributes
    attribute :session
    delegate :user, to: :session, allow_nil: true
  end
end
