require 'spec_helper'

describe Comment do
  context "Comment" do
    before(:each) do
      @comment = Factory.build(:comment)
    end
    
    it "should be valid with minimum attributes" do
      @comment.should be_valid
    end
    
  end
  
end
