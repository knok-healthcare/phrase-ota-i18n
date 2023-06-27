require "phrase/ota/version"
require "phrase/ota/configuration"
require "phrase/ota/backend"

module Phrase
  module Ota
    def self.configure
      yield(config) if block_given?
    end

    def self.config
      @config ||= Phrase::Ota::Configuration.new
    end
  end
end
