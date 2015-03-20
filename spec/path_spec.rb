require "spec_helper"
require "ostruct"

describe Takky::Path do
  let(:filename) { "hashed_filename.jpg" }
  let(:attachment) {
    OpenStruct.new(filename: "filename.jpg", id: 1, environment: "t")
  }

  let(:path) { described_class.new(attachment) }

  describe "#to_s" do
    # TODO: empty strings?
    it 'is "" if the attachment filename is blank' do
      attachment.filename = nil
      expect(path.to_s).to eql ""
    end

    it "returns the path otherwise" do
      expect(path.to_s).to eql "img/t/1/filename.jpg"
    end
  end

  describe "#root" do
    it "is nil if the attachment filename is blank" do
      attachment.filename = nil
      expect(path.root).to be_nil
    end

    it "returns the path otherwise" do
      expect(path.root).to eql "img/t/#{attachment.id}"
    end
  end
end
