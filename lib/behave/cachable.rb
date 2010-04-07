require 'active_support'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def cachable(options = {})
        options.symbolize_keys!

        unless cachable?
          class_inheritable_hash :cachable_options
          
          include Features            
        end
          
        self.cachable_options = options
      end
      
      private
        def cachable?
          false
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
            elsif self.class.cachable_options[:only]
              !self.class.cachable_options[:only].include?(key.to_sym)
            elsif self.class.cachable_options[:except]
              self.class.cachable_options[:except].include?(key.to_sym)
            else
              false
            end
          end
        end
      end
    end
  end
end
