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
    @region = Region.new
    authorize @region
  end

  def create
    @region = Region.new region_params
    authorize @region

    if @region.save
      redirect_to @region, flash: { success: 'Created region' }
    else
      render :new
    end
  end

  def edit
    authorize @region
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
        :name, :identifier, :country_code, :subnational,
        :latitude, :longitude, :radius, :restriction
      )
    end

end
