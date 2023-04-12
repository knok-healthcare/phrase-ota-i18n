module I18n
  module Backend
    class PhraseOta
      class Configuration
        attr_accessor :distribution_id
        attr_accessor :secret_token
        attr_accessor :logger
        attr_accessor :app_version
        attr_accessor :poll_interval_seconds
        attr_accessor :ota_base_url
        attr_accessor :datacenter
        attr_accessor :available_locales

        def initialize
          @distribution_id = nil
          @secret_token = nil
          @logger = Rails.logger
          @app_version = nil
          @poll_interval_seconds = 5
          @ota_base_url = "https://ota.phraseapp.com"
          @datacenter = "eu" # TODO support both datacenters
          @available_locales = []
        end
      end
    end
  end
end
