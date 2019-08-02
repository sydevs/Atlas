class VenuesController < ApplicationController

  before_action :set_venue!, only: %i[show edit update destroy]

  def index
    scope = Venue

    if params[:q]
      term = "%#{params[:q]}%"
      scope = scope.where('(name LIKE ?) OR (address LIKE ?)', term, term)
    end

    @venues = scope.includes(:events).page(params[:page]).per(10)
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

    def set_venue!
      @venue = Venue.find(params[:id])
    end

    def venue_params
      params.fetch(:venue, {}).permit(%i[
        name category latitude longitude
        contact_name contact_email
        street municipality subnational country_code
      ])
    end

end
