# frozen_string_literal: true

module Api
  module V1
    class TransportsController < BaseController
      include Api::V1::TransportsControllerDoc

      def index
        authorize(Transport)

        add_pagination_headers(transports)

        render json: transports.page(params[:page] || 1).per(params[:per_page] || 10)
      end

      def show
        authorize(transport)

        render json: transport
      end

      def create
        authorize(Transport)

        ActiveRecord::Base.transaction do
          transport = Transport.create!(transport_params)

          Transports::Publish.call(transport_id: transport.id) if params[:publish] == 'true'
        end

        render json: transport, status: :created
      end

      private

        def transports
          @transports ||= Transport.all
        end

        def transport
          @transport ||= Transport.find(params[:id])
        end

        def transport_params
          params.require(:transport).permit(
            :vehicle_license_plate, :tow_1_license_plate, :tow_2_license_plate,
            { start_address_attributes: permitted_address_attributes },
            { final_address_attributes: permitted_address_attributes }
          )
        end

        def permitted_address_attributes
          %i[name street street_number county_code city latitude longitude]
        end
    end
  end
end
