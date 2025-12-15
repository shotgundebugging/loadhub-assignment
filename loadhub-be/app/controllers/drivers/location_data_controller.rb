# frozen_string_literal: true

module Api
  module V1
    module Drivers
      class LocationDataController < BaseController
        include Api::V1::Drivers::LocationDataControllerDoc

        def create
          authorize(LocationDatum)

          LocationDatum.create(location_data_params)

          head :created
        end

        private

          def location_data_params
            params.require(:location_data).map do |location_datum|
              location_datum.permit(%i[transport_id latitude longitude timestamp])
            end
          end
      end
    end
  end
end
