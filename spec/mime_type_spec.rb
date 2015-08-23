require "spec_helper"

describe Takky::MimeType do
  include TakkySupport

  describe "#for" do
    specify do
      expect(described_class.for(image_fixture("fonzie.jpg"))).to eql "jpg"
    end

    specify do
      expect(described_class.for(image_fixture("rails.png"))).to eql "png"
    end
  end
end
