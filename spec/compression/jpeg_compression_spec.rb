require "spec_helper"

describe Takky::Compression::JpegCompression do
  describe "#compress" do
    specify do
      attachment = instance_double("Attachment", id: 1, extension: "jpg",
                                                 url: "//s3.amazonaws.com/img/t/1/hash.jpg")

      tf = Tempfile.new(%w(foo .jpg))
      mimg = double("MiniMagick::Image")
      expect(mimg).to receive(:quality).with(85)
      expect(mimg).to receive(:write) { instance_double("Tempfile", rewind: nil) }
      expect(MiniMagick::Image).to receive(:open).with("http:" + attachment.url) { mimg }

      described_class.new(attachment, 85, tf).compress
    end
  end
end
