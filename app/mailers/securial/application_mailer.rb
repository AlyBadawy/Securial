module Securial
  #
  # ApplicationMailer
  #
  # This class serves as the base mailer class for all Securial mailers.
  #
  # It inherits from ActionMailer::Base, allowing it to be used for sending
  # emails related to the Securial authentication and authorization system.
  #
  # This class can be extended to create specific mailers for notifications,
  # user communications, or other email-related functionality within the Securial
  # system.
  #
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"
  end
end
