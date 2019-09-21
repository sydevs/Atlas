class ManagersController < ApplicationController

  before_action :require_login!
  before_action :set_manager!, only: %i[show edit update destroy]

  def index
    authorize Manager
    scope = policy_scope(Manager)

    if params[:q]
      term = "%#{params[:q]}%"
      scope = scope.where('(name LIKE ?) OR (email LIKE ?)', term, term, term)
    end

    @managers = scope.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @manager = Manager.new
  end

  def create
    @manager = Manager.new manager_params

    if @manager.save
      redirect_to @manager, flash: { success: 'Created manager' }
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @manager.update manager_params
      redirect_to @manager, flash: { success: 'Saved manager' }
    else
      render :edit
    end
  end

  def destroy
    @manager.destroy
  end

  private

    def set_manager!
      @manager = Manager.find(params[:id])
    end

    def manager_params
      params.fetch(:manager, {}).permit(
        :name, :email, :administrator,
        country_ids: [], province_ids: [], local_area_ids: []
      )
    end

end
