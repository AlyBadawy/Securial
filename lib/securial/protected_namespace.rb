module Securial
  class << self
    # Returns the protected namespace for Securial routes.
    # This is used to scope routes and resources within the Securial engine.
    def protected_namespace
      "superusers"
    end
  end
end
