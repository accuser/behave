require 'spec_helper'

describe Behave::Serializable do
  class Document
    include Behave
    
    field :title
    field :body
  end
  
  class SerializableDocument < Document
    serializable
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:serializable?, true).should be true
  end

  it "should not include the serializable behavior" do
    Document.send(:serializable?).should be false
  end
  
  describe "#serializable" do
    it "should include the serializable behavior" do
      SerializableDocument.send(:serializable?).should be true
    end
    
    it "should define #serializable_attributes instance method" do
      SerializableDocument.new.should respond_to :serializable_attributes
    end
    
    describe "with :only condition" do
      class SerializableDocumentWithOnly < Document
        serializable :only => [ :title ]
      end

      before :each do
        @document = SerializableDocumentWithOnly.create(:title => 'Title', :body => 'This is a test')
      end

      after :each do
        @document.destroy
      end
      
      it "should return a filtered array of serializable attributes" do
        @document.serializable_attributes.keys.should =~ [ '_type', '_id', 'title' ]
      end
    end

    describe "with :except condition" do
      class SerializableDocumentWithExcept < Document
        serializable :except => [ :body ]
      end

      before :each do
        @document = SerializableDocumentWithExcept.create(:title => 'Title', :body => 'This is a test')
      end

      after :each do
        @document.destroy
      end
      
      it "should return a filtered array of serializable attributes" do
        @document.serializable_attributes.keys.should =~ [ '_type', '_id', 'title' ]
      end
    end
  end
  
  describe "#serializable_attributes" do
    before :each do
      @document = SerializableDocument.create(:title => 'Title', :body => 'This is a test')
    end
    
    after :each do
      @document.destroy
    end
    
    it "should return an array of serializable attributes" do
      @document.serializable_attributes.should == @document.attributes
    end
  end
  
  describe "#to_json" do
    before :each do
      @document = SerializableDocument.create(:id => 42, :title => 'Title', :body => 'This is a test')
    end
    
    after :each do
      @document.destroy
    end
    
    it "should return an valid JSON document fragment" do
      @document.to_json.should == "{\"body\":\"This is a test\",\"title\":\"Title\",\"_id\":42,\"_type\":\"SerializableDocument\"}"
    end
  end
end
