# TODO: Clean this up!

module SerializationOptions
  def self.extended(base)
    class << base
      class_inheritable_accessor :serialization_options
      attr_accessor :serialization_options
    end

    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def serialization_options=(value)
      @serialization_options = value
    end

    # Hop across to class if no instance serialization_options
    def serialization_options
      @serialization_options || self.class.serialization_options || self.class.superclass.serialization_options
    end
  end
end

class ActiveRecord::Serialization::Serializer

  # Silence warnings when serializing polymorphic records with a :type attribute
  def serializable_record_with_silencer
    silence_warnings do
      serializable_record_without_silencer
    end
  end

  # Add serialization options defined in the class of the record
  def initialize_with_serialization_options(record, options = {})
    options = record.serialization_options if record.respond_to? :serialization_options
    initialize_without_serialization_options(record, options || {}.with_indifferent_access)
  end

  alias_method_chain :serializable_record, :silencer
  alias_method_chain :initialize, :serialization_options

end
