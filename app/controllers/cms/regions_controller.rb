class CMS::RegionsController < CMS::ApplicationController

  prepend_before_action { @model = Region }

  def new
    super **fetch_osm_data(params[:osm_id])
  end

  def create
    super parameters
  end

  def edit
    super **fetch_osm_data(params[:osm_id])
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:region, {}).permit(:country_code, :name, :osm_id)
    end

    def fetch_osm_data osm_id=nil
      
      return {} if osm_id.nil?

      data = OpenStreetMapsAPI.fetch_data(osm_id)

      # if data[:address][:country_code] != country_code.downcase
      #   self.errors.add(:osm_id, :invalid, "is not within #{country_code}")
      #   return
      # end

      {
        name: data[:display_name].split(',', 2).first,
        osm_id: osm_id, 
        geojson: data[:geojson],
        bounds: data[:boundingbox],
        translations: data[:namedetails].to_a.filter_map do |key, value|
          key = key.to_s.split(':')
          [key[1] || 'en', value] if key[0] == 'name'
        end.to_h,
      }
    end

end
