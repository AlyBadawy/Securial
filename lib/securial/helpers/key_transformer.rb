# @title Securial Key Transformer Helpers
#
# Key transformation utilities for API response formatting in the Securial framework.
#
# This module provides utilities for transforming hash keys between different
# naming conventions (snake_case, camelCase, PascalCase) to ensure API responses
# follow consistent formatting standards regardless of Ruby's internal conventions.
#
# @example Converting keys to camelCase
#   data = { user_name: "john", email_address: "john@example.com" }
#   transformed = KeyTransformer.deep_transform_keys(data) { |key| KeyTransformer.camelize(key, :lowerCamelCase) }
#   # => { userName: "john", emailAddress: "john@example.com" }
#
# @example Converting nested structures
#   nested = { user: { first_name: "John", last_name: "Doe" } }
#   camelized = KeyTransformer.deep_transform_keys(nested) { |key| KeyTransformer.camelize(key, :lowerCamelCase) }
#   # => { user: { firstName: "John", lastName: "Doe" } }
#
module Securial
  module Helpers
    # Transforms hash keys between different naming conventions.
    #
    # This module provides methods to convert between snake_case (Ruby convention),
    # camelCase (JavaScript convention), and PascalCase (C# convention) for API
    # response formatting. It supports deep transformation of nested structures.
    #
    module KeyTransformer
      extend self

      # Converts a string to camelCase or PascalCase format.
      #
      # Transforms snake_case strings into camelCase variants based on the
      # specified format. Useful for converting Ruby hash keys to JavaScript
      # or other language conventions.
      #
      # @param [String, Symbol] str The string to transform
      # @param [Symbol] format The target camelCase format
      # @option format [Symbol] :lowerCamelCase Converts to lowerCamelCase (firstName)
      # @option format [Symbol] :UpperCamelCase Converts to PascalCase (FirstName)
      # @return [String] The transformed string, or original if format not recognized
      #
      # @example Converting to lowerCamelCase
      #   KeyTransformer.camelize("user_name", :lowerCamelCase)
      #   # => "userName"
      #
      # @example Converting to PascalCase
      #   KeyTransformer.camelize("email_address", :UpperCamelCase)
      #   # => "EmailAddress"
      #
      # @example Unrecognized format returns original
      #   KeyTransformer.camelize("user_name", :snake_case)
      #   # => "user_name"
      #
      def camelize(str, format)
        case format
        when :lowerCamelCase
          str.to_s.camelize(:lower)
        when :UpperCamelCase
          str.to_s.camelize
        else
          str.to_s
        end
      end

      # Converts a camelCase or PascalCase string to snake_case.
      #
      # Transforms camelCase or PascalCase strings back to Ruby's snake_case
      # convention. Useful for converting API input keys to Ruby conventions.
      #
      # @param [String, Symbol] str The string to transform
      # @return [String] The snake_case version of the string
      #
      # @example Converting from camelCase
      #   KeyTransformer.underscore("userName")
      #   # => "user_name"
      #
      # @example Converting from PascalCase
      #   KeyTransformer.underscore("EmailAddress")
      #   # => "email_address"
      #
      def self.underscore(str)
        str.to_s.underscore
      end

      # Recursively transforms all keys in a nested data structure.
      #
      # Applies a key transformation block to all hash keys in a deeply nested
      # structure containing hashes, arrays, and other objects. The transformation
      # preserves the structure while only modifying the keys.
      #
      # @param [Object] obj The object to transform (Hash, Array, or other)
      # @yieldparam [String, Symbol] key Each hash key to be transformed
      # @yieldreturn [String, Symbol] The transformed key
      # @return [Object] The transformed object with modified keys
      #
      # @example Transforming a simple hash
      #   data = { user_name: "john", user_email: "john@example.com" }
      #   KeyTransformer.deep_transform_keys(data) { |key| key.to_s.upcase }
      #   # => { "USER_NAME" => "john", "USER_EMAIL" => "john@example.com" }
      #
      # @example Transforming nested structures
      #   nested = {
      #     user_info: {
      #       first_name: "John",
      #       addresses: [
      #         { street_name: "Main St", zip_code: "12345" }
      #       ]
      #     }
      #   }
      #   result = KeyTransformer.deep_transform_keys(nested) { |key|
      #     KeyTransformer.camelize(key, :lowerCamelCase)
      #   }
      #   # => {
      #   #   userInfo: {
      #   #     firstName: "John",
      #   #     addresses: [
      #   #       { streetName: "Main St", zipCode: "12345" }
      #   #     ]
      #   #   }
      #   # }
      #
      # @example Non-hash objects are preserved
      #   mixed = ["string", 123, { user_name: "john" }]
      #   KeyTransformer.deep_transform_keys(mixed) { |key| key.to_s.upcase }
      #   # => ["string", 123, { "USER_NAME" => "john" }]
      #
      def self.deep_transform_keys(obj, &block)
        case obj
        when Hash
          obj.transform_keys(&block).transform_values { |v| deep_transform_keys(v, &block) }
        when Array
          obj.map { |e| deep_transform_keys(e, &block) }
        else
          obj
        end
      end
    end
  end
end
