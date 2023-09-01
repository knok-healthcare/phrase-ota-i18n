require "webmock/rspec"

describe Phrase::Ota::Backend do
  let(:distribution_id) { "123" }
  let(:secret_token) { "secret" }
  let(:available_locales) { %i[en de] }

  subject { I18n.backend }

  before do
    Phrase::Ota.configure do |config|
      config.distribution_id = distribution_id
      config.secret_token = secret_token
      config.available_locales = available_locales
    end

    @previous_backend = I18n.backend
    I18n.backend = Phrase::Ota::Backend.new
  end

  after do
    Phrase::Ota.configure do |config|
      config.available_locales = []
    end
    I18n.backend = @previous_backend
    I18n.config.clear_available_locales_set
  end

  context "#available_locales" do
    it do
      expect(subject.available_locales).to(eq(%i[en de]))
    end
  end

  context "update translations" do
    let(:distribution_id) { "b149aa004afebcde23b16ed6fd7e3793" }
    let(:secret_token) { "6zzpO8MWefkSuvAx4UVKYl30bNFcswwYi8DY2TbYjZ4" }

    context "with OTA backend" do
      let(:available_locales) { [:en] }
      let(:body_en) { {"en" => {"lorem" => "Hello OTA"}}.to_yaml }
      let(:url_en) { "https://ota.eu.phrase.com/#{distribution_id}/#{secret_token}/en/yml?app_version&client=ruby&sdk_version=#{Phrase::Ota::VERSION}" }

      context "translations should be updated" do
        before do
          stub_request(:get, url_en).to_return(status: 200, body: body_en)
        end

        it do
          subject.send(:update_translations)
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")
        end
      end

      context "init_translations should not reset translations" do
        let(:url_en_2) { "https://ota.eu.phrase.com/#{distribution_id}/#{secret_token}/en/yml?app_version&client=ruby&current_version=0&sdk_version=#{Phrase::Ota::VERSION}" }
        let(:body_en_2) { {"en" => {"lorem" => "Hello OTA New"}}.to_yaml }

        before do
          stub_request(:get, url_en).to_return(status: 200, body: body_en)
          stub_request(:get, url_en_2).to_return(status: 200, body: body_en_2)
        end

        it do
          subject.send(:update_translations)
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")

          subject.init_translations
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")

          subject.send(:update_translations)
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA New")
        end
      end

      context "store current_version per locale" do
        let(:available_locales) { [:en, :fr] }
        let(:body_fr) { {"fr" => {"lorem" => "Bonjour le monde"}}.to_yaml }
        let(:url_fr) { "https://ota.eu.phrase.com/#{distribution_id}/#{secret_token}/fr/yml?app_version&client=ruby&sdk_version=#{Phrase::Ota::VERSION}" }
        let(:url_en_2) { "https://ota.eu.phrase.com/#{distribution_id}/#{secret_token}/en/yml?app_version&client=ruby&current_version=0&sdk_version=#{Phrase::Ota::VERSION}" }

        before do
          stub_request(:get, url_en).to_return(status: 200, body: body_en)
          stub_request(:get, url_en_2).to_return(status: 200, body: body_en)
          stub_request(:get, url_fr).to_return({status: 404}, {status: 200, body: body_fr})
        end

        it do
          subject.send(:update_translations)
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")
          expect(I18n.t(:lorem, locale: :fr)).to eq("Translation missing: fr.lorem")

          subject.send(:update_translations)
          expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")
          expect(I18n.t(:lorem, locale: :fr)).to eq("Bonjour le monde")
        end
      end
    end
  end
end
