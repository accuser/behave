require 'active_support'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def serializable(options = {})
        options.symbolize_keys!

        class_inheritable_hash :serializable_options

        self.serializable_options = options

        include Behave::Serializable unless serializable?          
      end
      
      def serializable?
        false
      end
    end
  end
  
  module Serializable
    extend ActiveSupport::Concern

    module ClassMethods
      def serializable?
        true
      end
    end

    module InstanceMethods
      def serializable_attributes
        attributes.reject do |key, value|
          if [ :id, :_id, :type, :_type ].include?(key.to_sym)
            false
          elsif serializable_options[:only]
            !serializable_options[:only].include?(key.to_sym)
          elsif serializable_options[:except]
            serializable_options[:except].include?(key.to_sym)
          else
            false
          end
        end
      end
    
      def to_json(options = {})
        self.serializable_attributes.to_json options
      end

      def to_xml(options = {})
        self.serializable_attributes.to_xml options
      end
    
      private
        def serializable_options
          self.class.serializable_options
        end
    end
  end
end
