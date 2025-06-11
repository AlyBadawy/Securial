module Securial
  module Helpers
    module KeyTransformer
      module_function

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
end
