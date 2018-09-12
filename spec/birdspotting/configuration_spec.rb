RSpec.describe Birdspotting::Configuration do
  let(:instance) { described_class.new }

  describe ".default" do
    subject(:default) { described_class.default }

    it "returns an instance of Configuration" do
      expect(default).to be_a described_class
    end

    it "returns a different (new) instance every call" do
      other_default = described_class.default
      expect(default).not_to be other_default
    end
  end
end
