require "mini_magick"

module Takky
  module Compression
    class JpegCompression < BaseCompression
      def compress
        img = MiniMagick::Image.open("http:" + attachment.url(cdn: false))
        img.quality quality
        img.write(tempfile)
        tempfile.rewind
        tempfile
      end
    end
  end
end
