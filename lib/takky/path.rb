require "forwardable"

module Takky
  class Path
    extend Forwardable

    attr_reader :attachment, :prefix
    def_delegators :@attachment, :environment, :filename

    # TODO: this prefix should be configurable at the model level
    def initialize(attachment, prefix: "img")
      @attachment = attachment
      @prefix = prefix
    end

    def to_s
      r = root ? "#{root}/#{filename}" : ''
    end

    def root
      filename and "#{prefix}/#{environment}/#{attachment.id}"
    end
  end
end
