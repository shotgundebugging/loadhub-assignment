# frozen_string_literal: true

module Transports
  class Publish < Service::Base
    parameter :transport_id

    def init
      @transport = Transport.find(transport_id)
    end

    def call
      ActiveRecord::Base.transaction do
        transport.publish!
        validate_transport
        generate_uit
      end
    end

    private

      attr_reader :transport

      def validate_transport
        errors = Anaf::ValidateTransport.call(transport_id: transport.id).errors

        raise Anaf::TransportError, errors if errors.any?
      end

      def generate_uit
        uit = Anaf::GenerateUit.call(transport_id: transport.id).uit

        transport.update!(uit: uit)
      end
  end
end
