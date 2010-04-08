require 'active_support'
require 'mongoid'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def containable
        include Behave::Containable unless containable?        
      end
      
      private
        def containable?
          false
        end
    end
  end
  
  module Containable
    extend ActiveSupport::Concern

    included do
      belongs_to_related :container, :polymorphic => true
    end
  
    module ClassMethods
      private
        def containable?
          true
        end        
    end
  end
end
