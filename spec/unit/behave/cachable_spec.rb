require 'spec_helper'

describe Behave::Cachable do
  class Document
    include Behave
    
    field :title
    field :body
  end
  
  class CachableDocument < Document
    cachable
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:cachable?, true).should be true
  end

  it "should not include the cachable behavior" do
    Document.send(:cachable?).should be false
  end
  
  describe "#cachable" do
    it "should include the cachable behavior" do
      CachableDocument.send(:cachable?).should be true
    end
    
    it "should define #cachable_attributes instance method" do
      CachableDocument.new.should respond_to :cachable_attributes
    end
    
    describe "with :only condition" do
      class CachableDocumentWithOnly < Document
        cachable :only => [ :title ]
      end

      before :each do
        @document = CachableDocumentWithOnly.create(:title => 'Title', :body => 'This is a test')
      end

      after :each do
        @document.destroy
      end
      
      it "should return a filtered array of cachable attributes" do
        @document.cachable_attributes.keys.should =~ [ '_type', '_id', 'title' ]
      end
    end

    describe "with :except condition" do
      class CachableDocumentWithExcept < Document
        cachable :except => [ :body ]
      end

      before :each do
        @document = CachableDocumentWithExcept.create(:title => 'Title', :body => 'This is a test')
      end

      after :each do
        @document.destroy
      end
      
      it "should return a filtered array of cachable attributes" do
        @document.cachable_attributes.keys.should =~ [ '_type', '_id', 'title' ]
      end
    end
  end
  
  describe "#cachable_attributes" do
    before :each do
      @document = CachableDocument.create(:title => 'Title', :body => 'This is a test')
    end
    
    after :each do
      @document.destroy
    end
    
    it "should return an array of cachable attributes" do
      @document.cachable_attributes.should == @document.attributes
    end
  end
end
