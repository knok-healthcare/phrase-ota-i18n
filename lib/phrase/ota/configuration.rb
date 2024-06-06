require "logger"

module Phrase
  module Ota
    class UnknownDatacenterException < StandardError; end

    class Configuration
      attr_accessor :distribution_id
      attr_accessor :secret_token
      attr_accessor :logger
      attr_accessor :app_version
      attr_accessor :poll_interval
      attr_accessor :datacenter
      attr_accessor :available_locales
      attr_accessor :debug
      attr_accessor :yaml_permitted_classes
      attr_accessor :fetch_translations_on_boot
      attr_writer :base_url

      def initialize
        @distribution_id = nil
        @secret_token = nil
        @logger = Logger.new($stdout)
        @app_version = nil
        @poll_interval = 60
        @datacenter = "eu"
        @available_locales = []
        @base_url = nil
        @debug = false
        @yaml_permitted_classes = []
        @fetch_translations_on_boot = false
      end

      def base_url
        @base_url || datacenter_url
      end

      private

      def datacenter_url
        case @datacenter.downcase
        when "eu"
          "https://ota.eu.phrase.com"
        when "us"
          "https://ota.us.phrase.com"
        else
          raise UnknownDatacenterException
        end
      end
    end
  end
end
