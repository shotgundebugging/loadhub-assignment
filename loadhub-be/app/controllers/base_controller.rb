# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ApiErrorHandling
      include Pundit::Authorization

    protected

      def add_pagination_headers(collection)
        response.headers['X-Total'] = collection.size
        response.headers['X-Page'] = params[:page].to_i
        response.headers['X-Per-Page'] = params[:per_page].to_i
      end
    end
  end
end
