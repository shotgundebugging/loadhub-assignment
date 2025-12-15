# frozen_string_literal: true

# == Schema Information
#
# Table name: location_data
#
#  created_at            :datetime         not null
#  id                    :bigint           not null, primary key
#  latitude              :float            not null
#  longitude             :float            not null
#  timestamp             :datetime         not null
#  updated_at            :datetime         not null
#  vehicle_license_plate :string
#
# Indexes
#
#  index_carriers_on_transport_id         (transport_id)
#
# Foreign Keys
#
#  fk_rails_...  (transport_id => transports.id)
#
class LocationDatum < ApplicationRecord
  belongs_to :transport

  validates :latitude, :longitude, :timestamp, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
end
