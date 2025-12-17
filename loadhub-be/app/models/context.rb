class Current < ActiveSupport::CurrentAttributes
  attribute :company_id, :actor_type, :actor_id, :request_id, :ip, :user_agent
end
