module Takky
  module Compression
    CompressionError = Class.new(StandardError)

    autoload :BaseCompression, "takky/compression/base_compression"
    autoload :JpegCompression, "takky/compression/jpeg_compression"
    autoload :PngCompression, "takky/compression/png_compression"
  end
end
