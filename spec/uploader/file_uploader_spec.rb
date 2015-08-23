require "spec_helper"

describe Takky::Uploader::FileUploader do
  include DatabaseSupport

  describe "#update_extension" do
    it "updates the extension when necessary", integration: true do
      img = TakkyModelAttachment.create!(extension: "jpg", style: "promo_tile")
      expect(TakkyModelAttachment).to receive(:find).with(img.id) { img }

      Tempfile.create(%w(foo .png)) do |tf|
        u = described_class.new("TakkyModelAttachment", img.id, tf)
        expect(u.attachment.extension).to eql "png"
      end
    end
  end
end
