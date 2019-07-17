class VenuesController < ApplicationController

  before_action :set_venue!, only: %i[show edit update destroy]

  def index
    @venue = Venue.find(params[:id])
  end

  def show
  end

  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new venue_params

    if @venue.save
      redirect_to @venue, flash: { info: 'Created venue' }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @venue.update venue_params
      redirect_to @venue, flash: { info: 'Created venue' }
    else
      render :edit
    end
  end

  def destroy
    @venue.destroy
  end

  private

    def set_venues!
      if params[:q]
        term = "%#{params[:q]}%"
        @venues = Venue.where('(name LIKE ?) OR (address LIKE ?)', term, term)
      else
        @venues = Venue.includes(:events).limit(10)
        # @venues_count = Venue.all.count
      end
    end

    def venue_params
      params.fetch(:venue, {}).permit(
        :name, :category, :latitude, :longitude, :contact_email,
        :address_room, :address_street, :address_municipality, :address_subnational, :address_country
      )
    end

end
