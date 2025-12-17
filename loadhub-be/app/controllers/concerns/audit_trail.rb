module AuditTrail
  extend ActiveSupport::Concern

  AUDITED_CONTROLLERS = %w[transports addresses].freeze
  AUDITED_ACTIONS     = %w[show create update destroy].freeze

  included do
    after_action :audit_success
    rescue_from StandardError, with: :audit_failure_then_raise
  end

  private

  def audit_success
    return unless audited_endpoint?

    instrument_audit(errors: [])
  end

  def audit_failure_then_raise(error)
    raise error unless audited_endpoint?

    instrument_audit(errors: errors_for(error))
    raise error
  end

  def instrument_audit(errors:)
    action = "#{controller_name.singularize}.#{action_name}"
    subject = audited_subject
    subject_type = subject.class.name

    ActiveSupport::Notifications.instrument(
      "audit.#{action}",
      company_id: Context.company_id,
      actor_type: Context.actor_type,
      actor_id: Context.actor_id,
      subject_type:,
      subject_id: subject.id,
      action:,
      metadata: base_metadata,
      errors:
    )
  end

  def audited_endpoint?
    AUDITED_CONTROLLERS.include?(controller_name) && AUDITED_ACTIONS.include?(action_name)
  end

  def audited_subject
    public_send(controller_name.singularize) 
  end

  def base_metadata
    {
      request_id: Context.request_id,
      ip: Context.ip,
      user_agent: Context.user_agent,
    }
  end

  def errors_for(error)
    if error.is_a?(ActiveRecord::RecordInvalid)
      rec = error.record
      [{
        type: 'validation',
        messages: rec.errors.full_messages,
        details: rec.errors.to_hash(true)
      }]
    else
      [{ type: 'exception', class: error.class.name, message: error.message }]
    end
  end
end
