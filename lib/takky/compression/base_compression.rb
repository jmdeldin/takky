module Takky
  module Compression
    class BaseCompression
      attr_reader :attachment, :quality, :tempfile

      def initialize(attachment, quality, tempfile)
        @attachment = attachment
        @quality = quality
        @tempfile = tempfile
      end
    end
  end
end
