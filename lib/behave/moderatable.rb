require 'active_support'
require 'mongoid'
require 'mongoid/cached_document'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def moderatable(options = {})
        options.symbolize_keys!
        
        include Behave::Moderatable unless moderatable?

        if options.has_key? :before
          before_moderate options[:before]
        end
        
        if options.has_key? :after
          after_moderate options[:after]
        end
      end
    
      private
        def moderatable?
          false
        end
    end
  end
  
  module Moderatable
    extend ActiveSupport::Concern

    included do
      field :moderated, :type => Boolean, :default => false
      field :moderated_at, :type => Time
      field :moderated_by, :type => Mongoid::CachedDocument
      
      define_model_callbacks :moderate
    end

    module ClassMethods
      def moderated
        criteria.where :moderated => true
      end

      def moderated_by(moderator)
        moderated.where 'moderated_by._type' => moderator.class.to_s, 'moderated_by._id' => moderator.id
      end
      
      private
        def moderatable?
          true
        end
    end

    module InstanceMethods
      def moderate(moderator)
        unless moderated?
          _run_moderate_callbacks do
            update_attributes :moderated => true, :moderated_at => Time.now.utc, :moderated_by => moderator
          end
        end

        is_moderated_by? moderator
      end
      
      def is_moderated_by?(moderator)
        self.moderated? && self.moderated_by._type == moderator.class.to_s && self.moderated_by._id == moderator.class.to_s
      end
    end
  end
end
