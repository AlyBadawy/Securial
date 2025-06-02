module Securial
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    before_create :generate_uuid_v7

    private

    # Generates a UUIDv7 for the `id` field if it is blank.
    # This method is triggered by the `before_create` callback.
    # The generated ID is expected to be a UUIDv7 string.
    def generate_uuid_v7
      return if self.id.present?
      return unless [:string, :uuid].include?(self.class.type_for_attribute(:id).type)

      self.id ||= Random.uuid_v7
    end
  end
end
