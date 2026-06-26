module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found(e)
        render json: { error: e.message }, status: :not_found
      end

      def parameter_missing(e)
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
