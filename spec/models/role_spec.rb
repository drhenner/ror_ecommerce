require 'spec_helper'

describe Role do
  ##  These roles are preloaded from the seeds... lets make sure all the seeds are valid
  describe "Valid Seed data" do

    Role.all.each do |role|
      it "should be valid" do
        role.should be_valid
      end
    end

  end
end

describe Role, '#find_role_id(id)' do
  it "should return role from memcache" do
    first_role = Role.first
    role = Role.find_role_id(first_role.id)
    role.id.should == first_role.id

    # the second call exercizes memcache
    memcache_role = Role.find_role_id(first_role.id)
    memcache_role.id.should == first_role.id
  end
end

describe Role, '#find_role_name(name)' do
  it "should return role from memcache" do
    first_role = Role.first
    role = Role.find_role_name(first_role.name)
    role.id.should == first_role.id

    # the second call exercizes memcache
    memcache_role = Role.find_role_name(first_role.name)
    memcache_role.id.should == first_role.id
  end
end
