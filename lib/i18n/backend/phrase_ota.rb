require "faraday"
require "faraday_middleware"
require "i18n"

require_relative "phrase_ota/configuration"

module I18n
  module Backend
    class PhraseOta < I18n::Backend::Simple
      def self.configure
        yield(config) if block_given?
      end

      def self.config
        @config ||= Configuration.new
      end

      def initialize
        start_polling
      end

      def available_locales
        PhraseOta.config.available_locales
      end

      def init_translations
        @translations = {}
        @initialized = true
      end

      protected

      def start_polling
        Thread.new do
          loop do
            sleep(PhraseOta.config.poll_interval_seconds)
            update_translations
          end
        end
      end

      def update_translations
        PhraseOta.config.logger.info("Phrase: Updating translations...")

        available_locales.each do |locale|
          url = "#{PhraseOta.config.ota_base_url}/#{PhraseOta.config.distribution_id}/#{PhraseOta.config.secret_token}/#{locale}/yml"
          params = {
            app_version: PhraseOta.config.app_version,
            client: "ruby",
            sdk_version: Phrase::Ota::Rails::VERSION,
            current_version: 0 # TODO: cache current version,
            # last_update: Time.now.to_i # TODO: store last update timestamp
          }
          connection = Faraday.new do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter Faraday.default_adapter
          end

          PhraseOta.config.logger.info("Fetching URL: #{url}")

          response = connection.get(url, params, {"User-Agent" => "Phrase-OTA-Rails #{Phrase::Ota::Rails::VERSION}"})

          if response.status == 200
            yaml = YAML.safe_load(response.body)
            yaml.each do |yaml_locale, tree|
              store_translations(yaml_locale, tree || {})
            end
          end
        end
      end
    end
  end
end
