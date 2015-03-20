# Generate URLs for attachments.
module Takky
  class Url
    # @param [Image] image
    def initialize(image)
      @image = image
      @path  = Path.new(image)
    end

    # Returns the URL to the original attachment.
    def to_s(cdn: false, protocol: nil)
      return "" if @path.filename.blank?
      add_protocol(protocol, url_prefix(cdn: cdn).join(@path.to_s).to_s)
    end

    private

    def add_protocol(protocol, str)
      return str unless protocol
      protocol.sub(/:\z/, "") + ":#{str}"
    end

    def url_prefix(cdn: true)
      host = cdn ? Takky.config.cdn_host : Takky.config.src_host
      Pathname("//" + host)
    end
  end
end
