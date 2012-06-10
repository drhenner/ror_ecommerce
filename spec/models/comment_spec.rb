require 'spec_helper'

describe Comment do
  context "Comment" do
    before(:each) do
      User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
      @comment = build(:comment)
    end
    
    it "should be valid with minimum attributes" do
      @comment.should be_valid
    end
    
  end
  
end
