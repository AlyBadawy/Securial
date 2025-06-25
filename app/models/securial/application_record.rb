module Securial
  #
  # ApplicationRecord
  #
  # This class serves as the base model class for all Securial models.
  #
  # It inherits from ActiveRecord::Base and provides a common functionality for all models in the
  # Securial engine, including:
  #   - UUIDv7 generation for the `id` field
  #   - Abstract class definition to ensure it is not instantiated directly
  #
  #   - Custom behavior for the `before_create` callback to set the `id` field
  #
  # This class can be extended to add more model functionalities as needed.
  #
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    before_create :generate_uuid_v7

    private

    # Generates a UUIDv7 for the `id` field if it is blank.
    #
    # This method is triggered by the `before_create` callback.
    # The generated ID is expected to be a UUIDv7 string.
    #
    # @return [void]
    # @note This method will only set the `id` if it is not already present
    # and if the `id` field is of type string.
    def generate_uuid_v7
      return if self.id.present? || self.class.type_for_attribute(:id).type != :string

      self.id = Random.uuid_v7
    end
  end
end
