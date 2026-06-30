module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :authenticate_user!, only: [ :create ]
      skip_before_action :verify_authenticity_token

      private

      def respond_with(resource, _opts = {})
        token = request.env["warden-jwt_auth.token"]

        render json: {
          token: token,
          user: {
            id: resource.id,
            email: resource.email,
            role: resource.role
          }
        }, status: :ok
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end
