require "spec_helper"

class TestPath < TestCase
  let(:filename) { "hashed_filename.jpg" }
  let(:attachment) {
    OpenStruct.new(filename: "filename.jpg", id: 1, environment: "t")
  }

  let(:path) { described_class.new(attachment) }

  describe "#to_s" do
    # TODO: empty strings?
    it "is nil if the attachment filename is blank" do
      attachment.filename = nil
      path.to_s.must_equal nil
    end

    it "returns the path otherwise" do
      path.to_s.must_equal "img/t/1/filename.jpg"
    end
  end

  describe "#root" do
    it "is nil if the attachment filename is blank" do
      attachment.filename = nil
      path.root.must_equal nil
    end

    it "returns the path otherwise" do
      path.root.must_equal "img/t/#{attachment.id}"
    end
  end
end
