# frozen_string_literal: true

module Clients
  class BaseClient
    include HTTParty
    debug_output $stdout if Rails.env.development?

    def get(path, query:)
      response = self.class.get(path, query:)
      JSON.parse(response.body.to_s)
    end
  end
end
