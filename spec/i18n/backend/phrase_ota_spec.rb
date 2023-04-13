require "webmock/rspec"

describe I18n::Backend::PhraseOta do
  let(:distribution_id) { "123" }
  let(:secret_token) { "secret" }
  let(:available_locales) { %i[en de] }

  before do
    I18n::Backend::PhraseOta.configure do |config|
      config.distribution_id = distribution_id
      config.secret_token = secret_token
      config.available_locales = available_locales
    end
  end

  after do
    I18n::Backend::PhraseOta.configure do |config|
      config.available_locales = []
    end
  end

  context "#available_locales" do
    subject { I18n::Backend::PhraseOta.new }

    it do
      expect(subject.available_locales).to(eq(%i[en de]))
    end
  end

  context "update translations" do
    let(:distribution_id) { "b149aa004afebcde23b16ed6fd7e3793" }
    let(:secret_token) { "6zzpO8MWefkSuvAx4UVKYl30bNFcswwYi8DY2TbYjZ4" }

    context "with OTA backend" do
      let(:available_locales) { [:en] }

      subject { I18n::Backend::PhraseOta.new }

      before do
        I18n.backend = subject
        subject.init_translations

        body_en = {"en" => {"lorem" => "Hello OTA"}}.to_yaml
        url_en = "https://ota.phraseapp.com/#{distribution_id}/#{secret_token}/en/yml?app_version&client=ruby&sdk_version=0.1.0"
        stub_request(:get, url_en)
          .to_return(status: 200, body: body_en, headers: {})
      end

      it do
        subject.send(:update_translations)

        expect(I18n.t(:lorem, locale: :en)).to eq("Hello OTA")
      end
    end
  end
end
