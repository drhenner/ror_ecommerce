require 'spec_helper'
def cookied_admin_login
   User.acts_as_authentic_config[:maintain_sessions] = false
   create(:admin_user, :email => 'test@admin.com', :password => 'secret1', :password_confirmation => 'secret1')
   visit login_path
   within("#login") do
     fill_in 'Email',    :with => 'test@admin.com'
     fill_in 'Password', :with => 'secret1'
     click_button 'Log In'
   end
end
def cookied_login
   User.acts_as_authentic_config[:maintain_sessions] = false
   create(:user, :first_name => 'Dave', :email => 'test@nonadmin.com', :password => 'secret1', :password_confirmation => 'secret1')
   visit login_path
   within("#login") do
     fill_in 'Email',    :with => 'test@nonadmin.com'
     fill_in 'Password', :with => 'secret1'
     click_button 'Log In'
   end
end

describe "Admin::Overviews" do
  describe "GET /admin_overviews" do
    it "works!" do

      visit admin_overviews_path
      page.should have_content('admin_user_')
      page.should have_content('notarealemail')
      User.first.should_not be_nil
    end
  end
end
describe "Admin::Overviews" do
  describe "GET /admin_overviews" do
    it "If a user has already been created this page will show without password info for admin users" do
      cookied_admin_login

      visit admin_overviews_path
      page.should have_content('It would be best to go')
    end
  end
end
describe "Admin::Overviews" do
  describe "GET /admin_overviews" do
    it "If a user has already been created this page will redirect to root_url for non-admins" do
      #User.create!(:first_name => 'Dave', :last_name => 'Henner',:email => 'test@admin.com', :password => 'secret1', :password_confirmation => 'secret1')
      user = create(:admin_user)
      visit admin_overviews_path
      #response.should redirect_to( root_url)
      page.should have_content('Login or')
      page.should have_content('Sign up')
    end
  end

  describe "GET /admin_overviews" do
    it "If a user has already been created this page will redirect to root_url for non-admins" do
      cookied_login
      visit admin_overviews_path
      #response.should redirect_to( root_url)
      page.should have_content('Dave')
      page.should have_content('not you')
    end
  end
end
