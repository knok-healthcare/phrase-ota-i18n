require "rails/generators"

module PhraseOta
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Creates a Phrase OTA initializer for your Rails application."
    class_option :distribution_id, type: :string, desc: "Your Phrase OTA distribution ID", required: true
    class_option :secret_token, type: :string, desc: "Your Phrase OTA secret token", required: true

    def copy_initializer
      template "phrase_ota.rb", "config/initializers/phrase_ota.rb"
    end

    def show_readme
      readme "README.md" if behavior == :invoke
    end
  end
end
