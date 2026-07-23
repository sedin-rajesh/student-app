module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      respond_to :json
      before_action :authenticate_user!
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found(e)
        render json: { error: {
          type: "record_not_found",
          message: "Record not found: #{e.model} with ID #{e.id}"
        }
      }, status: :not_found
      end

      def parameter_missing(e)
        render json: { error: {
          type: "parameter_missing",
          message: "One or more required parameters are missing: #{e.param}"
        }
      }, status: :bad_request
      end

      def render_validation_error(record)
        render json: {
          errors: record.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end
