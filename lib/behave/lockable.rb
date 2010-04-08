require 'active_support'
require 'mongoid'
require 'mongoid/cached_document'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def lockable(options = {})
        class_inheritable_hash :lockable_options
        
        options.symbolize_keys!
        options.reverse_merge! :timeout => 15.minutes
        
        self.lockable_options = options
        
        include Behave::Lockable unless lockable?
      end
      
      private
        def lockable?
          false
        end
    end
  end
  
  module Lockable
    extend ActiveSupport::Concern
  
    included do
      field :locked, :type => Boolean, :default => false
      field :locked_at, :type => Time
      field :locked_by, :type => Mongoid::CachedDocument
    end
  
    module ClassMethods
      def locked
        criteria.where :locked => true, :locked_at.gt => lockable_options[:timeout].ago
      end
    
      def locked_by(locker)
        locked.where 'locked_by._type' => locker.class.to_s, 'locked_by._id' => locker.id
      end
      
      private
        def lockable?
          true
        end
    end
  
    module InstanceMethods
      def lock(locker)
        if is_locked_by? locker
          update_attributes :locked_at => Time.now.utc
        elsif self.locked?
          false
        else
          update_attributes :locked => true, :locked_at => Time.now.utc, :locked_by => locker
        end
        
        is_locked_by? locker
      end
    
      def is_locked_by?(locker)
        self.locked? && self.locked_by._type == locker.class.to_s && self.locked_by._id == locker.id
      end
      
      def unlock(locker)
        if is_locked_by? locker
          update_attributes :locked => false, :locked_by => nil
        end
      
        unlocked?
      end
    
      def unlocked?
        !locked?
      end
    end
  end
end
