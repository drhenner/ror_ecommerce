require 'rubygems'
require 'spec'
require 'active_support'
require 'action_view' # ugly but temporary

require File.dirname(__FILE__) + '/../lib/2dc_jqgrid'
Array.send :include, JqgridJson
include Jqgrid

class User
  attr_accessor :id
  attr_accessor :username
  attr_accessor :email
  attr_accessor :password
  attr_accessor :parent
  
  def initialize(options = {})
    @id       = options[:id]
    @username = options[:username]
    @email    = options[:email]
    @password = options[:password]
  end
  
  def a_virtual_attribute
    username.reverse
  end
  
  def to_json # This method is available by default on all ActiveRecord objects
    "{\"user\": {\"username\": \"#{username}\", \"id\": #{id}, \"email\": \"#{email}\", \"password\": \"#{password}\"}}"
  end
  
  def attributes # This method is available by default on all ActiveRecord objects
    { 'id' => id, 'username' => username, 'email' => email, 'password' => password }
  end
end

describe "to_jqgrid_json" do
  
  before(:each) do 
    @data = []
    5.times do |i|
      @data << User.new(:id => i+1, :username => "user_#{i+1}", :email => "user_#{i+1}@test.be", :password => "a_password")
    end
  end
  
  it "should generate a valid JSON representation of the data" do
    json = @data.to_jqgrid_json([:id, :username, :email, :password], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"1\",\"cell\":[\"1\",\"user_1\",\"user_1@test.be\",\"a_password\"]},{\"id\":\"2\",\"cell\":[\"2\",\"user_2\",\"user_2@test.be\",\"a_password\"]},{\"id\":\"3\",\"cell\":[\"3\",\"user_3\",\"user_3@test.be\",\"a_password\"]},{\"id\":\"4\",\"cell\":[\"4\",\"user_4\",\"user_4@test.be\",\"a_password\"]},{\"id\":\"5\",\"cell\":[\"5\",\"user_5\",\"user_5@test.be\",\"a_password\"]}]}"
  end
  
  it "should include only specified attributes" do
    json = @data.to_jqgrid_json([:id, :username], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"1\",\"cell\":[\"1\",\"user_1\"]},{\"id\":\"2\",\"cell\":[\"2\",\"user_2\"]},{\"id\":\"3\",\"cell\":[\"3\",\"user_3\"]},{\"id\":\"4\",\"cell\":[\"4\",\"user_4\"]},{\"id\":\"5\",\"cell\":[\"5\",\"user_5\"]}]}"
  end
  
  it "should include virtual attributes if they are specified" do
    json = @data.to_jqgrid_json([:id, :username, :a_virtual_attribute], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"1\",\"cell\":[\"1\",\"user_1\",\"1_resu\"]},{\"id\":\"2\",\"cell\":[\"2\",\"user_2\",\"2_resu\"]},{\"id\":\"3\",\"cell\":[\"3\",\"user_3\",\"3_resu\"]},{\"id\":\"4\",\"cell\":[\"4\",\"user_4\",\"4_resu\"]},{\"id\":\"5\",\"cell\":[\"5\",\"user_5\",\"5_resu\"]}]}"
  end
  
  it "should not generate rows if there is no data" do
    @data = []
    json = @data.to_jqgrid_json([:id, :username], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"0\"}"
  end
  
  it "should use the index of the array as an ID if no ID is specified" do
    @data.each { |user| user.id = nil }
    json = @data.to_jqgrid_json([:username], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"0\",\"cell\":[\"user_1\"]},{\"id\":\"1\",\"cell\":[\"user_2\"]},{\"id\":\"2\",\"cell\":[\"user_3\"]},{\"id\":\"3\",\"cell\":[\"user_4\"]},{\"id\":\"4\",\"cell\":[\"user_5\"]}]}"
  end
  
  it "should be possible to specify nested attributes using associations" do
    @data.each do |user|
      parent = User.new(:username => "Parent #{user.id}")
      user.parent = parent
    end
    json = @data.to_jqgrid_json([:id, :username, "parent.username"], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"1\",\"cell\":[\"1\",\"user_1\",\"Parent 1\"]},{\"id\":\"2\",\"cell\":[\"2\",\"user_2\",\"Parent 2\"]},{\"id\":\"3\",\"cell\":[\"3\",\"user_3\",\"Parent 3\"]},{\"id\":\"4\",\"cell\":[\"4\",\"user_4\",\"Parent 4\"]},{\"id\":\"5\",\"cell\":[\"5\",\"user_5\",\"Parent 5\"]}]}"
  end
  
  it "should be possible to specify nested attributes using associations on multiple levels" do
    @data.each do |user|
      parent = User.new(:username => "Parent #{user.id}")
      parent_of_parent = User.new(:username => "Parent Parent #{user.id}")
      parent.parent = parent_of_parent
      user.parent = parent
    end
    json = @data.to_jqgrid_json([:id, :username, "parent.username", "parent.parent.username"], 1, 10, @data.size)
    json.should == "{\"page\":\"1\",\"total\":1,\"records\":\"5\",\"rows\":[{\"id\":\"1\",\"cell\":[\"1\",\"user_1\",\"Parent 1\",\"Parent Parent 1\"]},{\"id\":\"2\",\"cell\":[\"2\",\"user_2\",\"Parent 2\",\"Parent Parent 2\"]},{\"id\":\"3\",\"cell\":[\"3\",\"user_3\",\"Parent 3\",\"Parent Parent 3\"]},{\"id\":\"4\",\"cell\":[\"4\",\"user_4\",\"Parent 4\",\"Parent Parent 4\"]},{\"id\":\"5\",\"cell\":[\"5\",\"user_5\",\"Parent 5\",\"Parent Parent 5\"]}]}"
  end
  
  it "should return an empty string if the associated object is nil" do
    json = @data.to_jqgrid_json([:id, "parent.username"], 1, 10, @data.size)
    p json
  end
  
end

module JqgridTestHelper
  def jqgrid_shortcut(options = {})
    jqgrid("Users", "users", "/users",
            [
          		{ :field => "id", :label => "ID", :width => 35 },
          		{ :field => "username", :label => "Username" },
          		{ :field => "email", :label => "Email" },
          		{ :field => "password", :label => "Password" }
          	], options
          )
  end
end

describe "jqgrid helper method" do
  
  include JqgridTestHelper
  
  describe "generating a simple jqgrid without options" do
  
    before(:each) do
      @grid = jqgrid_shortcut
    end
  
    it "should generate required HTML tags and set them in the JS" do
      @grid.include?(%Q(<table id="users")).should be_true
      @grid.include?(%Q(<div id="users_pager")).should be_true
      @grid.include?(%Q(jQuery("#users").jqGrid)).should be_true
      @grid.include?(%Q(pager: '#users_pager')).should be_true
    end
    
    it "should set a title and an URL" do
      @grid.include?(%Q(caption: "Users")).should be_true
      @grid.include?(%Q(url:'/users?q=1')).should be_true
    end
  
    it "should generate a valid data model" do
      @grid.include?("datatype: \"json\"").should be_true
      @grid.include?(%Q(colNames:['ID','Username','Email','Password'])).should be_true
      @grid.include?(%Q(colModel:[{name:'id', index:'id',width:35},{name:'username', index:'username'},{name:'email', index:'email'},{name:'password', index:'password'}])).should be_true
    end
    
  end
  
  describe "generating a jqgrid with options" do
    
    it "should be possible to disable the search toolbar" do
      @grid = jqgrid_shortcut(:search => false)
      @grid.include?(%Q(mygrid.filterToolbar();)).should be_false
      @grid.include?("toggleToolbar").should be_false
    end
    
    it "should be possible to overwrite sorting default behaviors" do
      @grid = jqgrid_shortcut(:sort_column => 'username', :sort_order => 'desc')
      @grid.include?("sortname: 'username'").should be_true
      @grid.include?("sortorder: 'desc'").should be_true
    end
    
    it "should be possible to resize the grid" do
      @grid = jqgrid_shortcut(:height => 500, :autowidth => true)
      @grid.include?("height: 500").should be_true
      @grid.include?("autowidth: true").should be_true
    end
    
    it "should be possible to show row numbers and set rows per page" do
      @grid = jqgrid_shortcut(:rows_per_page => 5, :rownumbers => true)
      @grid.include?("rowNum:5").should be_true
      @grid.include?("rownumbers: true").should be_true
    end
    
    it "should be possible to improve performance on big sets using gridview" do
      @grid = jqgrid_shortcut(:gridview => true)
      @grid.include?("gridview: true").should be_true
    end
    
    it "should be possible to configure a selection handler" do
      @grid = jqgrid_shortcut(:selection_handler => "handleSelection", :direct_selection => true)
      @grid.include?("onSelectRow").should be_true
      @grid.include?("handleSelection(id)").should be_true
    end
    
    it "should be possible to use multiple selection (using checkboxes)" do
      @grid = jqgrid_shortcut(:selection_handler => "handleSelection", :multi_selection => true)
      @grid.include?("multiselect: true").should be_true
    end
    
    it "should be possible to perform master-details between two grids" do
      @grid = jqgrid_shortcut(:master_details => true, :details_url => "/users/details", :details_caption => "User Details")
      @grid.include?(%Q(jQuery("#users_details"))).should be_true
      @grid.include?(%Q\setGridParam({url:"/users/details\).should be_true
      @grid.include?(%Q\setCaption("User Details\).should be_true
    end
    
    it "should be able to enable data manipulation" do
      @grid = jqgrid_shortcut(:add => true, :edit => true, :delete => true, :edit_url => "/users/post_data", :error_handler => "afterSubmit")
      @grid.include?("edit:true").should be_true
      @grid.include?("add:true").should be_true
      @grid.include?("del:true").should be_true
      @grid.include?("editurl:'/users/post_data'").should be_true
      @grid.include?("return afterSubmit(r,data,'add')").should be_true
      @grid.include?("return afterSubmit(r,data,'edit')").should be_true
      @grid.include?("return afterSubmit(r,data,'delete')").should be_true
    end
    
    it "should be possible to configure inline editing" do
      @grid = jqgrid_shortcut(:edit => true, :inline_edit => true)
      @grid.include?(%Q(jQuery('#users').editRow)).should be_true
      @grid.include?(%Q(jQuery('#users').restoreRow)).should be_true
    end
    
    it "should be possible to add basic subgrid" do
      @grid = jqgrid("Users", "users", "/users",
      	[
      		{ :field => "id", :label => "ID", :width => 35 },
      		{ :field => "pseudo", :label => "Pseudo" },
      		{ :field => "firstname", :label => "Firstname" },
      		{ :field => "lastname", :label => "Lastname" },
      		{ :field => "email", :label => "Email" },
      		{ :field => "role", :label => "Role" }
      	],
      	{ 
      		:subgrid => { :url => "/users/pets",
      					  :columns => [
      						{ :field => "id", :label => "ID", :width => 35 },
      						{ :field => "name", :label => "Name" }
      					  ]
      					}
      	}
      )
      @grid.include?("subGrid:true").should be_true
      @grid.include?("subGridRowExpanded").should be_true
      @grid.include?(%Q(url:"/users/pets?q=2)).should be_true
      @grid.include?("colModel: [{name:'id', index:'id',width:35},{name:'name', index:'name'}]").should be_true
    end
    
    it "shoud be possible to add subgrids with CRUD operations" do
      @grid = jqgrid("Football Players", "players_10", "/users",
      	[
      		{ :field => "id", :label => "ID", :width => 35 },
      		{ :field => "pseudo", :label => "Pseudo" },
      		{ :field => "firstname", :label => "Firstname" },
      		{ :field => "lastname", :label => "Lastname" },
      		{ :field => "email", :label => "Email" },
      		{ :field => "role", :label => "Role" }
      	],
      	{ 
      		:subgrid => { :url => "/users/pets", :edit_url => "/users/post_pets_data", :add => true, :edit => true, :delete => true,
      					  :columns => [
      						{ :field => "id", :label => "ID", :width => 35, :editable => true },
      						{ :field => "name", :label => "Name", :editable => true }
      					  ]
      					}
      	}
      )
      
      @grid.include?("{edit:true,add:true,del:true,search:false}").should be_true
      @grid.include?("editurl:'/users/post_pets_data?parent_id='+row_id").should be_true
    end
    
  end
  
  it "should be possible to customize forms" do
    @grid = jqgrid("Users", "users", "/users",
    	[
    		{ :field => "id", :label => "ID", :width => 35, :resizable => false },
    		{ :field => "pseudo", :label => "Pseudo", :editable => true, :formoptions => { :rowpos => 1, :elmprefix => "(*)&nbsp;&nbsp;" }, :editoptions => { :size => 18 }, :editrules => { :required => true } },
    		{ :field => "firstname", :label => "Firstname", :editable => true,  :formoptions => { :rowpos => 4, :label => "A label" }, :editoptions => { :size => 22 } },
    		{ :field => "lastname", :label => "Lastname", :editable => true, :formoptions => { :rowpos => 5 }, :editoptions => { :size => 22 } },
    		{ :field => "email", :label => "Email", :editable => true, :formoptions => { :rowpos => 3 }, :editoptions => { :size => 22 } },
    		{ :field => "role", :label => "Role", :editable => true, :stype => "select", :edittype => "select", :formoptions => { :rowpos => 2 }, :editoptions => { :value => [["admin","admin"], ["player", "player"], ["defender","defender"]], :size => 22 } }
    	],
    	{ :add => true, :edit => true, :inline_edit => true, :delete => true, :edit_url => "/users/post_data" }
    )
    @grid.include?(%Q(olModel:[{name:'id', index:'id',width:35,resizable:false},{name:'pseudo', index:'pseudo',editoptions:{size:18},editable:true,editrules:{required:true},formoptions:{rowpos:1,elmprefix:\"(*)&nbsp;&nbsp;\"}},{name:'firstname', index:'firstname',editoptions:{size:22},editable:true,formoptions:{rowpos:4,label:\"A label\"}},{name:'lastname', index:'lastname',editoptions:{size:22},editable:true,formoptions:{rowpos:5}},{name:'email', index:'email',editoptions:{size:22},editable:true,formoptions:{rowpos:3}},{name:'role', index:'role',editoptions:{value:\"admin:admin;player:player;defender:defender\",size:22},editable:true,formoptions:{rowpos:2},stype:'select',edittype:'select'}])).should be_true
  end
  
end