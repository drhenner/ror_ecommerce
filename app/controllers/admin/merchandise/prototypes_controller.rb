class Admin::Merchandise::PrototypesController < Admin::BaseController
  helper_method :sort_column, :sort_direction

  def index
    @prototypes = Prototype.admin_grid(params).order(sort_column + " " + sort_direction).
                                              paginate(page: pagination_page, per_page: pagination_rows)
  end

  def new
    @all_properties = Property.all
    if @all_properties.empty?
      flash[:notice] = "You must create a property before you create a prototype."
      redirect_to new_admin_merchandise_property_path
    else
      @prototype      = Prototype.new(active: true)
      @prototype.properties.build
    end
  end

  def create
    @prototype = Prototype.new(allowed_params)

    if @prototype.save
      @prototype.update_attributes(property_ids: params[:prototype][:property_ids])
      redirect_to action: :index
    else
      @all_properties = Property.all
      flash[:error] = "The prototype property could not be saved"
      render action: :new
    end
  end

  def edit
    @all_properties = Property.all
    @prototype = Prototype.includes(:properties).find(params[:id])
  end

  def update
    @prototype = Prototype.find(params[:id])
@prototype.property_ids = params[:prototype][:property_ids]
    if @prototype.update_attributes(allowed_params)
      redirect_to action: :index
    else
      @all_properties = Property.all
      render action: :edit
    end
  end

  def destroy
    @prototype = Prototype.find(params[:id])
    @prototype.active = false
    @prototype.save

    redirect_to action: :index
  end
  private

  def allowed_params
    params.require(:prototype).permit( :name, :active )
  end

  def sort_column
    Prototype.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

end
