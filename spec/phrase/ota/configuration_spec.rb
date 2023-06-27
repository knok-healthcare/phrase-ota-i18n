describe Phrase::Ota::Configuration do
  before do
    Phrase::Ota.configure do |config|
      config.datacenter = datacenter
    end
  end

  after do
    Phrase::Ota.configure do |config|
      config.datacenter = "eu"
    end
  end

  context "#base_url" do
    context "with eu datacenter" do
      let(:datacenter) { "eu" }

      it do
        expect(Phrase::Ota.config.base_url).to(eq("https://ota.phraseapp.com"))
      end
    end

    context "with us datacenter" do
      let(:datacenter) { "us" }

      it do
        expect(Phrase::Ota.config.base_url).to(eq("https://us.ota.phrase.com"))
      end
    end

    context "with invalid datacenter" do
      let(:datacenter) { "fr" }

      it do
        expect { Phrase::Ota.config.base_url }.to raise_error(Phrase::Ota::UnknownDatacenterException)
      end
    end
  end
end
