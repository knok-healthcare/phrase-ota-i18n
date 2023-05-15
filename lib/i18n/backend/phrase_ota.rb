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
        @current_version = nil
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
          url = "#{PhraseOta.config.base_url}/#{PhraseOta.config.distribution_id}/#{PhraseOta.config.secret_token}/#{locale}/yml"
          params = {
            app_version: PhraseOta.config.app_version,
            client: "ruby",
            sdk_version: Phrase::Ota::Rails::VERSION
          }
          params[:current_version] = @current_version unless @current_version.nil?

          connection = Faraday.new do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter Faraday.default_adapter
          end

          PhraseOta.config.logger.info("Phrase: Fetching URL: #{url}")

          response = connection.get(url, params, {"User-Agent" => "Phrase-OTA-Rails #{Phrase::Ota::Rails::VERSION}"})
          next unless response.status == 200

          @current_version = CGI.parse(URI(response.env.url).query)["version"].first.to_i
          yaml = YAML.safe_load(response.body)
          yaml.each do |yaml_locale, tree|
            store_translations(yaml_locale, tree || {})
          end
        end
      end
    end
  end
end
