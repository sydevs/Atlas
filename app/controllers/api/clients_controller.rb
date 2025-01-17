class API::ClientsController < API::ApplicationController

  def show
    @client = Client.find_by_public_key!(params[:id])
    @client.touch(:last_accessed_at)
  end

end
