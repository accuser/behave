require 'active_support'
require 'mongoid'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def timestamp(options = {})
        options.symbolize_keys!
        options.reverse_merge! :create => true, :update => true
        
        include Behave::Timestamped unless timestamped?

        if options[:create]
          field :created_at, :type => Time
          before_save :set_created_at, :if => :set_created_at?
        end
        
        if options[:update]
          field :updated_at, :type => Time
          before_save :set_updated_at, :if => :set_updated_at?
        end
      end
    
      private
        def timestamp?
          false
        end
    end
  end
  
  module Timestamped
    extend ActiveSupport::Concern

    module ClassMethods
      private
        def timestamp?
          true
        end
    end
      
    module InstanceMethods
      def set_created_at
        self.created_at = Time.now.utc
      end

      def set_created_at?
        self.new_record?
      end
      
      def set_updated_at
        self.updated_at = Time.now.utc
      end
      
      def set_updated_at?
        self.new_record? == false
      end
    end
  end
end
