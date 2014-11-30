require 'spec_helper'

describe Role do
  ##  These roles are preloaded from the seeds... lets make sure all the seeds are valid
  describe "Valid Seed data" do

    Role.all.each do |role|
      it "should be valid" do
        expect(role).to be_valid
      end
    end

  end
end
