# frozen_string_literal: true

# == Schema Information
#
# Table name: transport_addresses
#
#  city              :string
#  code              :integer
#  created_at        :datetime         not null
#  id                :bigint           not null, primary key
#  latitude          :decimal(10, 6)
#  longitude         :decimal(10, 6)
#  name              :string
#  postal_code       :string
#  street            :string
#  street_number     :string
#  updated_at        :datetime         not null
#
class TransportAddress < ApplicationRecord
  validates :city, length: { maximum: 100 }, 
  validates :street, length: { maximum: 100 }, allow_nil: true
  validates :postal_code, length: { maximum: 20 }, allow_nil: true
  validates :street_number, length: { maximum: 20 }, allow_nil: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
end
