describe I18n::Backend::Configuration do
  before do
    I18n::Backend::PhraseOta.configure do |config|
      config.datacenter = datacenter
    end
  end

  after do
    I18n::Backend::PhraseOta.configure do |config|
      config.datacenter = "eu"
    end
  end

  context "#base_url" do
    context "with eu datacenter" do
      let(:datacenter) { "eu" }

      it do
        expect(I18n::Backend::PhraseOta.config.base_url).to(eq("https://ota.phraseapp.com"))
      end
    end

    context "with us datacenter" do
      let(:datacenter) { "us" }

      it do
        expect(I18n::Backend::PhraseOta.config.base_url).to(eq("https://us.ota.phrase.com"))
      end
    end

    context "with invalid datacenter" do
      let(:datacenter) { "fr" }

      it do
        expect { I18n::Backend::PhraseOta.config.base_url }.to raise_error(I18n::Backend::UnknownDatacenterException)
      end
    end
  end
end
