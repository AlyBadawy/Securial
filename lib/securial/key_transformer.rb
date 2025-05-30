# lib/securial/key_transformer.rb
module Securial
  module KeyTransformer
    def self.camelize(str, format)
      return str unless str.is_a?(String)

      case format
      when :lowerCamelCase
        str.camelize(:lower)
      when :UpperCamelCase
        str.camelize
      else
        str
      end
    end

    def self.underscore(str)
      str.to_s.underscore
    end

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
