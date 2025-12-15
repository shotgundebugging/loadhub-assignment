# frozen_string_literal: true

# == Schema Information
#
# Table name: transports
#
#  company_id                     :bigint
#  created_at                     :datetime         not null
#  final_address_id               :bigint
#  id                             :bigint           not null, primary key
#  published_at                   :datetime
#  start_address_id               :bigint
#  tow_1_license_plate            :string
#  tow_2_license_plate            :string
#  uit                            :string
#  updated_at                     :datetime         not null
#  vehicle_license_plate          :string
#
# Indexes
#
#  index_transports_on_company_id                 (company_id)
#  index_transports_on_final_address_id           (final_address_id)
#  index_transports_on_start_address_id           (start_address_id)
#
# Foreign Keys
#
#  fk_rails_...  (final_address_id => transport_addresses.id)
#  fk_rails_...  (start_address_id => transport_addresses.id)
#
# rubocop:disable Metrics/ClassLength
class Transport < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :start_address, class_name: 'TransportAddress', optional: true
  belongs_to :final_address, class_name: 'TransportAddress', optional: true

  has_many :transport_statuses, -> { order(happened_at: :asc) }, dependent: :destroy
  has_many :location_data, dependent: :destroy

  def publish!
    ActiveRecord::Base.transaction do
      self.published_at = Time.zone.now
      save!
    end
  end
end
