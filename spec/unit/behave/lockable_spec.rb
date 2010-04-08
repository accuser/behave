require 'spec_helper'

describe Behave::Lockable do
  class Document
    include Behave
  end
  
  class LockableDocument < Document
    lockable
  end
  
  class Locker
    include Behave
  end
  
  def mock_locker(stubs = {})
    @mock_locker ||= mock(Locker, stubs)
  end
  
  it "should be included with Behave mixin" do
    Document.respond_to?(:lockable?, true).should be true
  end

  it "should not include the lockable behavior" do
    Document.send(:lockable?).should be false
  end
  
  describe "#lockable" do
    it "should include the lockable behavior" do
      LockableDocument.send(:lockable?).should be true
    end
    
    it "should define #locked class method" do
      LockableDocument.should respond_to :locked
    end
    
    it "should define #locked_by class method" do
      LockableDocument.should respond_to :locked_by
    end
    
    it "should define #locked instance method" do
      LockableDocument.new.should respond_to :locked
      LockableDocument.new.should respond_to :locked=
    end

    it "should define #locked_at instance method" do
      LockableDocument.new.should respond_to :locked_at
      LockableDocument.new.should respond_to :locked_at=
    end

    it "should define #locked_by instance method" do
      LockableDocument.new.should respond_to :locked_by
      LockableDocument.new.should respond_to :locked_by=
    end
  end
  
  describe "#locked" do
    it "should return a criteria for selecting locked documents" do
      LockableDocument.locked.selector[:locked].should be true
    end
  end

  describe "#locked_by" do
    before :each do
      mock_locker.stub(:class).and_return(Locker)
      mock_locker.stub(:id).and_return(42)
    end
    
    it "should return a criteria for selecting locked documents locked by a specific locker" do
      selector = LockableDocument.locked_by(mock_locker).selector
      
      selector[:locked].should be true
      selector['locked_by._type'].should == 'Locker'
      selector['locked_by._id'].should be 42 
    end
  end
  
  describe "locking a document" do
    before :each do
      @document = LockableDocument.create
      
      mock_locker.stub(:class).and_return(Locker)
      mock_locker.stub(:id).and_return(42)
    end
    
    after :each do
      @document.destroy
    end
        
    describe "when unlocked" do
      it "should mark the document as locked" do
        lambda do
          @document.lock(mock_locker)
        end.should change(@document, :locked).from(false).to(true)
      end
    
      it "should record the time at which the document was locked" do
        time_now = Time.now
      
        Time.stub!(:now).and_return(time_now)
      
        @document.lock(mock_locker)
        @document.locked_at.to_s.should == time_now.utc.to_s
      end
    
      it "should record the locker of the document" do
        Locker.stub!(:find).with(42).and_return(mock_locker)
      
        @document.lock(mock_locker)
        @document.locked_by.should be mock_locker
      end
      
      it "should succeed" do
        @document.lock(mock_locker).should be true
      end
    end
    
    describe "when locked by the locker" do
      before :each do
        @document.lock(mock_locker)
      end
      
      it "should update the time at which the document was locked" do
        time_now = Time.now
      
        Time.stub!(:now).and_return(time_now)
      
        @document.lock(mock_locker)
        @document.locked_at.to_s.should == time_now.utc.to_s
      end

      it "should succeed" do
        @document.lock(mock_locker).should be true
      end
    end
    
    describe "when locked" do
      before :each do
        @document.lock(mock(Locker, :class => Locker, :id => 37))
      end
      
      it "should fail" do
        @document.lock(mock_locker).should be false
      end
    end
  end
end
