# frozen_string_literal: true

module ApiErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |exception|
      render json: {
        message: not_found_error_message(exception),
        code: 'not_found'
      }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      render json: {
        message: 'Validation Failed',
        **ValidationErrorsSerializer.new(exception.record).serialize
      }, status: :unprocessable_entity
    end

    rescue_from ActionController::ParameterMissing do |exception|
      render json: {
        message: "Parameter missing: #{exception.param}",
        code: 'param_missing'
      }, status: :unprocessable_entity
    end

    rescue_from ActiveModel::UnknownAttributeError do |error|
      render json: {
        message: error.message,
        code: :unprocessable_entity
      }, status: :unprocessable_entity
    end

    rescue_from Pundit::NotAuthorizedError do |_error|
      render json: {
        message: I18n.t('errors.messages.forbidden'),
        code: :forbidden
      }, status: :forbidden
    end
  end
end
