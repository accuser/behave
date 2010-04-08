require 'active_model'
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
          elsif self.serializable_options[:only]
            !self.serializable_options[:only].include?(key.to_sym)
          elsif self.serializable_options[:except]
            self.serializable_options[:except].include?(key.to_sym)
          else
            false
          end
        end
      end
    
      def to_json(options = nil)
        serializable_attributes.to_json options
      end
    end
  end
end
