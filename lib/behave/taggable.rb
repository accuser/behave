require 'active_support'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def taggable(options = {})
        options.symbolize_keys!
        options.reverse_merge! :on => [ :tags ]

        class_inheritable_hash :taggable_options
        self.taggable_options = options
        
        self.taggable_options[:on].each do |context|
          (class << self; self; end).__send__(:define_method, context) do
            criteria.only("#{context}").collect { |doc| doc.__send__ "#{context}" }.flatten.uniq.compact
          end
          
          define_method "#{context.to_s.singularize}_list=" do |tags|
            __send__("#{context.to_s}=", tags.split(/[^\w]+/).collect { |tag| tag.downcase.strip }.uniq.compact)
          end

          define_method "#{context.to_s.singularize}_list" do
            if __send__("#{context.to_s}")
              __send__("#{context.to_s}").join(", ")
            else
              ""
            end
          end
        end

        include Behave::Taggable
      end
    end
  end

  module Taggable
    extend ActiveSupport::Concern
  
    included do
      self.taggable_options[:on].each do |context|
        field context, :type => Array
        index context
      end
    end
    
    module ClassMethods
      def tags
        criteria.only(self.taggable_options[:on]).collect do |doc|
          self.taggable_options[:on].collect do |context|
            doc.__send__(context)
          end
        end.flatten.uniq.compact
      end
      
      def tagged_with(tags)
        criteria.where("$or" => self.taggable_options[:on].inject([]) { |m, o| m << { o => { "$in" => tags.to_a }}})
      end
    end
  end
end
