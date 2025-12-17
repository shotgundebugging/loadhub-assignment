# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ApiErrorHandling
      include Pundit::Authorization
      include AuditTrail

      around_action :set_current

      protected

      def add_pagination_headers(collection)
        response.headers['X-Total'] = collection.size
        response.headers['X-Page'] = params[:page].to_i
        response.headers['X-Per-Page'] = params[:per_page].to_i
      end
    end

    def set_current
      Context.company_id = current_user.company_id
      Context.actor_type = current_user.class.name
      Context.actor_id = current_user.id
      Context.request_id = request.request_id
      Context.ip = request.remote_ip
      Context.user_agent = request.user_agent
    end
  end
end
