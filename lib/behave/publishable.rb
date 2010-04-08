require 'active_support'
require 'mongoid'
require 'mongoid/cached_document'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def publishable(options = {})
        options.symbolize_keys!
        
        include Behave::Publishable unless publishable?

        if options.has_key? :before
          before_publish options[:before]
        end
        
        if options.has_key? :after
          after_publish options[:after]
        end
      end
    
      private
        def publishable?
          false
        end
    end
  end
  
  module Publishable
    extend ActiveSupport::Concern

    included do
      field :published, :type => Boolean, :default => false
      field :published_at, :type => Time
      field :published_by, :type => Mongoid::CachedDocument
      
      define_model_callbacks :publish
    end

    module ClassMethods
      def published
        criteria.where :published => true
      end

      def published_by(publisher)
        published.where 'published_by._type' => publisher.class.to_s, 'published_by._id' => publisher.id
      end
      
      private
        def publishable?
          true
        end
    end

    module InstanceMethods
      def publish(publisher)
        unless published?
          _run_publish_callbacks do
            update_attributes :published => true, :published_at => Time.now, :published_by => publisher
          end
        end

        is_published_by? publisher
      end
      
      def is_published_by?(publisher)
        self.published? && self.published_by._type == publisher.class.to_s && self.published_by._id == publisher.class.to_s
      end
    end
  end
end
