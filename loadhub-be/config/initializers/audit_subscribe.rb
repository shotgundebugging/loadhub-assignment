ActiveSupport::Notifications.subscribe(/^audit\./) do |name, _start, _finish, _id, payload|
  AuditEvent.from_notification(name:, payload:)
end
