class Regions::CountriesController < ApplicationController

  before_action :require_login!
  before_action :set_country!, only: %i[show edit update destroy]

  def index
    authorize Regions::Country
    @countries = policy_scope(Regions::Country)
    country_codes = @countries.map(&:country_code)
    @unpersisted_countries = I18nData.countries(I18n.locale).map { |k,v| [v, k] unless country_codes.include?(k) }.compact
  end

  def show
    authorize @country

    @unpersisted_provinces = ::SubdivisionSelect::SubdivisionsHelper.get_subdivisions(@country.country_code) || false
  end

  def new
    @country = Regions::Country.new(country_code: params[:country_code])
    authorize @country
  end

  def create
    @country = Regions::Country.new(country_params)
    authorize @country

    if @country.save
      redirect_to @country, flash: { success: 'Created country' }
    else
      render :new
    end
  end

  def edit
    authorize @country
  end

  def update
    authorize @country
    if @country.update country_params
      redirect_to @country, flash: { success: 'Saved country' }
    else
      render :edit
    end
  end

  def destroy
    authorize @country
    @country.destroy
  end

  private

    def set_country!
      @country = Regions::Country.find(params[:id])
    end

    def country_params
      params.fetch(:regions_country, {}).permit(:country_code)
    end

end
