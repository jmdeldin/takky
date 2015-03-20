require "spec_helper"

describe Takky::Compression::PngCompression do
  include TakkySupport

  describe "#compress" do
    let(:attachment) {
      instance_double("Attachment", id: 1, extension: "png",
                                    url: "//s3.amazonaws.com/img/t/1/hash.png")
    }

    it "works" do
      Tempfile.create(%w(foo .png)) do |tf|
        png = image_fixture("tellafriend-get25.png")
        fh = File.open(png, "r")

        compresser = described_class.new(attachment, 1, tf)
        expect(compresser).to receive(:fetch_image) { fh }
        compresser.compress

        expect(File.new(png).size).to be > File.new(tf).size
        fh.close
      end
    end

    it "throws an exception if pngquant errors" do
      Tempfile.create(%w(foo .png)) do |tf|
        bad_image = image_fixture("fonzi.jpg")
        fh = File.open(bad_image, "r")

        compresser = described_class.new(attachment, 1, tf)
        expect(compresser).to receive(:fetch_image) { fh }

        expect { compresser.compress }.to raise_error(Takky::Compression::CompressionError)

        expect(File.new(bad_image).size).to be > File.new(tf).size
        fh.close
      end
    end
  end
end
