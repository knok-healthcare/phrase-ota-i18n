module I18n
  module Backend
    class PhraseOta
      class Configuration
        attr_accessor :distribution_id
        attr_accessor :secret_token
        attr_accessor :logger
        attr_accessor :app_version

        def initialize
          @distribution_id = nil
          @secret_token = nil
          @logger = Rails.logger
          @app_version = nil
        end
      end
    end
  end
end
