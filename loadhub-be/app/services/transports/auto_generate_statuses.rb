# frozen_string_literal: true

class Transports::AutoGenerateStatuses < Service::Base
  parameters :transport_id

  def init
    @transport = Transport.find(transport_id)
  end

  def call
    # TODO
  end
end
