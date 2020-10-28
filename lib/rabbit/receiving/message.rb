# frozen_string_literal: true

require "tainbox"

require "rabbit/receiving/malformed_message"

module Rabbit::Receiving
  class Message
    include Tainbox

    attribute :group_id
    attribute :project_id
    attribute :message_id
    attribute :routing_key
    attribute :event
    attribute :data
    attribute :original_message

    def self.build(message, type:, app_id:, message_id: nil, **)
      group_id, project_id = app_id.split(".")

      new(
        group_id: group_id,
        project_id: project_id,
        event: type,
        data: message,
        message_id: message_id,
      )
    end

    def data=(value)
      self.original_message = value
      super(JSON.parse(value).deep_symbolize_keys)
    rescue JSON::ParserError => error
      mark_as_malformed!("JSON::ParserError: #{error.message}")
    end

    def mark_as_malformed!(errors = "Error not specified")
      MalformedMessage.raise!(self, errors, caller(1))
    end
  end
end
