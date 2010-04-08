require 'active_support'

module Behave
  module Behaviors
    extend ActiveSupport::Concern
  
    module ClassMethods
      def versionable
        include Behave::Versionable unless versionable?        
      end
      
      private
        def versionable?
          false
        end
    end
  end
  
  module Versionable
    extend ActiveSupport::Concern

    included do
      field :version, :type => Integer, :default => 1
      
      embeds_many :versions, :class_name => self.name
      
      before_save :revise
    end
    
    module ClassMethods
      private
        def versionable?
          true
        end
    end

    module InstanceMethods
      def current_version
        @current_version ||= self.class.first(:conditions => { :_id => self.id, :version => self.version })
      end
      
      def revise
        _run_revise_callbacks do
          self.versions << current_version.clone
          self.version = self.version + 1
        end
      end
      
      private
        def versionable_options
          self.class.versionable_options
        end
    end
  end
end
