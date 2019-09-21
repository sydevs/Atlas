class VenuesController < ApplicationController

  before_action :require_login!
  before_action :set_venue!, only: %i[show edit update destroy]

  def index
    authorize Venue
    scope = policy_scope(Venue)

    if params[:q]
      term = "%#{params[:q]}%"
      scope = scope.where('(name LIKE ?) OR (street LIKE ?) OR (municipality LIKE ?) OR (subnational LIKE ?) OR (country_code LIKE ?)', term, term, term, term, term)
    end

    @venues = scope.includes(:events).page(params[:page]).per(10)
  end

  def show
    authorize @venue
  end

  def new
    @venue = Venue.new
    authorize @venue
  end

  def create
    @venue = Venue.new venue_params
    authorize @venue

    if @venue.save
      redirect_to @venue, flash: { success: 'Created venue' }
    else
      render :new
    end
  end

  def edit
    authorize @venue
  end

  def update
    authorize @venue
    if @venue.update venue_params
      redirect_to @venue, flash: { success: 'Saved venue' }
    else
      render :edit
    end
  end

  def destroy
    authorize @venue
    @venue.destroy
  end

  private

    def set_venue!
      @venue = Venue.find(params[:id])
    end

    def venue_params
      params.fetch(:venue, {}).permit(
        :name, :category, :latitude, :longitude,
        :street, :municipality, :subnational, :country_code,
        manager: {}
      )
    end

end
