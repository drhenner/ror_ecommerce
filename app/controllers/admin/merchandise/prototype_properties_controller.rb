class Admin::Merchandise::PrototypePropertiesController < Admin::BaseController
  
  respond_to :html, :json

=begin
  def index
    @prototype_properties = PrototypeProperty.admin_grid(params)
    respond_to do |format|
      format.html
      format.json { render :json => @prototype_properties.to_jqgrid_json(
        [ :display_name, :display_active ],
        @prototype_properties.per_page, #params[:page],
        @prototype_properties.current_page, #params[:rows],
        @prototype_properties.total_entries)
        
      }
    end
  end
  
  def show
    @prototype_property = PrototypeProperty.find(params[:id])
    respond_with(@prototype_property)
  end
=end
  def new
    #@properties = Property.all
    @prototype_property = PrototypeProperty.new(params[:prototype_property]) 
    render :template => 'admin/merchandise/prototype_properties/new', :layout => false
  end
=begin
  def create
    @prototype_property = PrototypeProperty.new(params[:prototype_property])
    
    if @prototype_property.save
      redirect_to :action => :index
    else
      @properties = Property.all
      flash[:error] = "The prototype property could not be saved"
      render :action => :new
    end
  end
  
  def edit
    @properties = Property.all
    @prototype_property = PrototypeProperty.find(params[:id])
  end
  
  def update
    @prototype_property = PrototypeProperty.find(params[:id])
    
    if @prototype_property.update_attributes(params[:prototype_property])
      redirect_to :action => :index
    else
      @properties = Property.all
      render :action => :edit
    end
  end
  
  def destroy
    @prototype_property = PrototypeProperty.find(params[:id])
    @prototype_property.active = false
    @prototype_property.save
    
    redirect_to :action => :index
  end
=end
end
