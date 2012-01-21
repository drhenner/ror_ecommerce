class Admin::Merchandise::PrototypesController < Admin::BaseController
  helper_method :sort_column, :sort_direction
  respond_to :html, :json
  def index
    @prototypes = Prototype.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(:per_page => 20, :page => params[:page].to_i)
    respond_to do |format|
      format.html
    end
  end

  def new
    @all_properties = Property.all
    if @all_properties.empty?
      flash[:notice] = "You must create a property before you create a prototype."
      redirect_to new_admin_merchandise_property_path
    else
      @prototype      = Prototype.new(:active => true)
      @prototype.properties.build
    end
  end

  def create
    @prototype = Prototype.new(params[:prototype])

    if @prototype.save
      redirect_to :action => :index
    else
      @all_properties = Property.all
      flash[:error] = "The prototype property could not be saved"
      render :action => :new
    end
  end

  def edit
    @all_properties = Property.all
    @prototype = Prototype.includes(:properties).find(params[:id])
  end

  def update
    @prototype = Prototype.find(params[:id])

    if @prototype.update_attributes(params[:prototype])
      redirect_to :action => :index
    else
      @all_properties = Property.all
      render :action => :edit
    end
  end

  def destroy
    @prototype = Prototype.find(params[:id])
    @prototype.active = false
    @prototype.save

    redirect_to :action => :index
  end
  private

  def sort_column
    Prototype.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
