Rails.configuration.to_prepare do
  GraphiQL::Rails::EditorsController.class_eval do
    include Passwordless::ControllerHelpers

    before_action :authenticate_user!

    def authenticate_user!
      return if authenticate_by_session(Manager)
      
      redirect_to managers_sign_in_path, flash: { error: translate('cms.messages.not_logged_in') }
    end
  end 
end