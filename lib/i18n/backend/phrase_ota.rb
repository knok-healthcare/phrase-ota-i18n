require "i18n/backend/base"
require "faraday"
require "faraday_middleware"

require_relative "phrase_ota/configuration"

module I18n
  module Backend
    class PhraseOta
      class << self
        def configure
          yield(config) if block_given?
        end

        def config
          @config ||= Configuration.new
        end
      end

      def initialize
        start_polling
      end

      module Implementation
        include Base

        def store_translations(locale, data, _options = EMPTY_HASH)
          # TODO: Do we need this?
          # if I18n.enforce_available_locales &&
          #   I18n.available_locales_initialized? &&
          #   !I18n.locale_available?(locale)
          #   return data
          # end

          locale = locale.to_sym
          translations[locale] ||= Concurrent::Hash.new
          data = data.deep_symbolize_keys
          translations[locale].deep_merge!(data)
        end

        def available_locales
          PhraseOta.config.available_locales
        end

        def reload!
          @translations = nil
          self
        end

        def initialized?
          !@translations.nil?
        end

        def init_translations
          @translations = {}
        end

        def translations(do_init: false)
          init_translations if do_init || !initialized?
          @translations ||= {}
        end

        protected

        def lookup(locale, key, scope = [], options = EMPTY_HASH)
          init_translations unless initialized?
          keys = I18n.normalize_keys(locale, key, scope, options[:separator])

          keys.inject(translations) do |result, key|
            return nil unless result.is_a?(Hash)

            unless result.has_key?(key)
              key = key.to_s.to_sym
              return nil unless result.has_key?(key)
            end
            result = result[key]
            result = resolve(locale, key, result, options.merge(scope: nil)) if result.is_a?(Symbol)
            result
          end
        end

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
              current_version: 0, # TODO: cache current version,
              last_update: Time.now.to_i # TODO: store last update timestamp
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

      include Implementation
    end
  end
end
