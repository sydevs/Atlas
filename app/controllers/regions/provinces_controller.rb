class Regions::ProvincesController < ApplicationController

  before_action :require_login!
  before_action :set_parent!, only: %i[new create]
  before_action :set_province!, only: %i[show edit update destroy]

  def show
    authorize @province
  end

  def new
    @province = @country.provinces.new(province_name: params[:province_name])
    authorize @province
  end

  def create
    @province = @country.provinces.new(province_params)
    authorize @province

    if @province.save
      redirect_to @province, flash: { success: 'Created province' }
    else
      render :new
    end
  end

  def edit
    authorize @province
  end

  def update
    authorize @province
    if @province.update province_params
      redirect_to @province, flash: { success: 'Saved province' }
    else
      render :edit
    end
  end

  def destroy
    authorize @province
    @province.destroy
  end

  private

    def set_parent!
      @country = Regions::Country.find(params[:country_id])
    end

    def set_province!
      @province = Regions::Province.find(params[:id])
    end

    def province_params
      params.fetch(:regions_province, {}).permit(:country_code, :province_name)
    end

end
