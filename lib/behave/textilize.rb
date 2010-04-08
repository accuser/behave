require 'active_support'
require 'nokogiri'
require 'RedCloth'

module Behave
  module Behaviors
    extend ActiveSupport::Concern

    module ClassMethods
      def textilize(*args)
        options = args.extract_options!

        args.each do |attribute|
          define_method("#{attribute}_raw") do
            read_attribute("#{attribute}")
          end

          define_method(attribute) do
            doc = RedCloth.new(__send__("#{attribute}_raw").to_s)
            
            unless options[:tags].blank?
              options[:tags].each do |tag|
                doc.extend tag
              end
            end
            
            if options[:rules].blank?
              doc.to_html
            else
              doc.to_html(*options[:rules])
            end
          end

          define_method("#{attribute}_plain") do
            Nokogiri(__send__("#{attribute}")).content
          end
        end
      end
    end
  end
end
