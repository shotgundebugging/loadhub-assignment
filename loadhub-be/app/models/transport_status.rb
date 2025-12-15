# frozen_string_literal: true

# == Schema Information
#
# Table name: transport_statuses
#
#  created_at     :datetime         not null
#  happened_at    :datetime         not null
#  id             :bigint           not null, primary key
#  status         :integer          not null
#  transport_id   :bigint           not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transport_statuses_on_status        (status)
#  index_transport_statuses_on_transport_id  (transport_id)
#
# Foreign Keys
#
#  fk_rails_...  (transport_id => transports.id)
#
class TransportStatus < ApplicationRecord
  belongs_to :transport

  validates :status, :happened_at, presence: true

  enum :status, {
    draft: 0,
    ready: 1,
    moving: 2,
    paused: 3,
    finalised: 4
  }
end
