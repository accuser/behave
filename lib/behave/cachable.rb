require 'active_support'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def cachable(options = {})
        class_inheritable_hash :cachable_options

        options.symbolize_keys!
        
        self.cachable_options = options

        include Behave::Cachable unless cachable?        
      end
      
      private
        def cachable?
          false
        end
    end
  end
  
  module Cachable
    extend ActiveSupport::Concern

    module ClassMethods
      private
        def cachable?
          true
        end
    end

    module InstanceMethods
      def cachable_attributes
        attributes.reject do |key, value|
          if [ :id, :_id, :type, :_type ].include?(key.to_sym)
            false
          elsif self.cachable_options[:only]
            !self.cachable_options[:only].include?(key.to_sym)
          elsif self.cachable_options[:except]
            self.cachable_options[:except].include?(key.to_sym)
          else
            false
          end
        end
      end
    end
  end
end
