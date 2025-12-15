# frozen_string_literal: true

module Api
  module V1
    class AddressesController < BaseController
      include Api::V1::AddressesControllerDoc

      def index
        authorize(Address)

        add_pagination_headers(addresses)

        render json: addresses.page(params[:page] || 1).per(params[:per_page] || 10)
      end

      def create
        authorize(Address)

        address = Address.create!(address_params)

        render json: address, status: :created
      end

      def show
        authorize(address)

        render json: address
      end

      def update
        authorize(address)

        address.update!(address_params)

        render json: address
      end

      def destroy
        authorize(address)

        address.destroy!

        head :ok
      end

      private

        def addresses
          addresses ||= Address.all
        end

        def address
          address ||= Address.find(params[:id])
        end

        def address_params
          params.require(:address)
                .permit(
                  :name,
                  :street,
                  :street_number,
                  :building_number,
                  :county_code,
                  :city,
                  :latitude,
                  :longitude
                )
        end
    end
  end
end
