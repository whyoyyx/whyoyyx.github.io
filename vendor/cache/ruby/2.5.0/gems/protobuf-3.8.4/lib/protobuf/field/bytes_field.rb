require 'protobuf/wire_type'

module Protobuf
  module Field
    class BytesField < BaseField

      ##
      # Constants
      #

      BYTES_ENCODING = Encoding::BINARY

      ##
      # Class Methods
      #

      def self.default
        ''
      end

      ##
      # Public Instance Methods
      #

      def acceptable?(val)
        val.is_a?(String) || val.nil? || val.is_a?(Symbol) || val.is_a?(::Protobuf::Message)
      end

      def decode(bytes)
        bytes_to_decode = bytes.dup
        bytes_to_decode.force_encoding(::Protobuf::Field::BytesField::BYTES_ENCODING)
        bytes_to_decode
      end

      def encode(value)
        value_to_encode =
          if value.is_a?(::Protobuf::Message)
            value.encode
          else
            value.dup
          end

        value_to_encode.force_encoding(::Protobuf::Field::BytesField::BYTES_ENCODING)
        string_size = ::Protobuf::Field::VarintField.encode(value_to_encode.size)

        "#{string_size}#{value_to_encode}"
      end

      def encode_to_stream(value, stream)
        value = value.encode if value.is_a?(::Protobuf::Message)
        byte_size = ::Protobuf::Field::VarintField.encode(value.bytesize)

        stream << tag_encoded << byte_size << value
      end

      def wire_type
        ::Protobuf::WireType::LENGTH_DELIMITED
      end

      def coerce!(value)
        case value
        when String, Symbol
          value.to_s
        when NilClass
          nil
        when ::Protobuf::Message
          value.dup
        else
          fail TypeError, "Unacceptable value #{value} for field #{name} of type #{type_class}"
        end
      end

      def json_encode(value)
        Base64.strict_encode64(value)
      end
    end
  end
end
