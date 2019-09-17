class RegionsController < ApplicationController

  before_action :require_login!
  before_action :set_region!, only: %i[show edit update destroy]

  def index
    authorize Region
    scope = policy_scope(Region)

    if params[:q]
      term = "%#{params[:q]}%"
      scope = scope.where('(name LIKE ?) OR (country LIKE ?) OR (city LIKE ?)', term, term, term)
    end

    @regions = scope.page(params[:page]).per(10)
  end

  def show
    authorize @region
  end

  def new
    @parent = Region.find(params[:id]) if params[:id]
    @region = @parent ? @parent.subregions.new : Region.new
    @region.type = @parent[:type] - 1
    authorize @region

    if @region.local?
      @title = "Create Region within #{@region.state_name}, #{@region.country}"
    elsif @region.state?
      @title = "Create Region within #{@region.country_name}"
    else
      @title = "Create Region"
    end
  end

  def create
    @parent = Region.find(params[:id]) if params[:id]
    @region = @parent ? @parent.subregions.new(region_params) : Region.new(region_params)
    @region.type = @parent[:type] - 1
    authorize @region

    if @region.save
      redirect_to @region, flash: { success: 'Created region' }
    else
      render :new
    end
  end

  def edit
    authorize @region

    if @region.local?
      @title = "Create Region within #{@region.state_name}, #{@region.country}"
    elsif @region.state?
      @title = "Create Region within #{@region.country_name}"
    else
      @title = "Create Region"
    end
  end

  def update
    authorize @region
    if @region.update region_params
      redirect_to @region, flash: { success: 'Saved region' }
    else
      render :edit
    end
  end

  def destroy
    authorize @region
    @region.destroy
  end

  private

    def set_region!
      @region = Region.find(params[:id])
    end

    def region_params
      params.fetch(:region, {}).permit(
        :name, :identifier, :country, :subnational,
        :latitude, :longitude, :radius, :restriction
      )
    end

end
