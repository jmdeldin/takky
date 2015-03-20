require "open-uri"
require "open3"

module Takky
  module Compression
    class PngCompression < BaseCompression
      def compress
        source = fetch_image

        args = %W(-f --output #{tempfile.path} --speed #{quality} #{source.path})
        Open3.popen3("pngquant", *args) do |_stdin, _stdout, stderr|
          err = stderr.read
          raise CompressionError.new(err) unless err.empty?
        end

        tempfile
      end

      private

      def fetch_image
        url = attachment.url(cdn: false, protocol: "http")
        open(url)
      end
    end
  end
end
