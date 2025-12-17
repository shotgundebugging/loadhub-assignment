class AuditEvent < ApplicationRecord
  REQUIRED_KEYS = %i[company_id actor_type actor_id subject_id subject_type action].freeze

  def self.from_notification(name:, payload:)
    company_id, actor_type, actor_id, subject_id, subject_type, action = 
      payload.fetch_values(*REQUIRED_KEYS)

    create!(
      company_id:,
      actor_type:,
      actor_id:,
      subject_id:,
      subject_type:,
      action:,
      metadata: payload.fetch(:metadata, {}),
      errors: payload.fetch(:errors, [])
    )
end
