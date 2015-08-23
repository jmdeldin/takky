require "mime/types"

module Takky
  class MimeType
    def self.for(filename)
      mime_type = MIME::Types.of(filename).first
      mime_type && map_common(mime_type.extensions.first)
      # TODO: consider bumping mime_types version requirement
    end

    private

    # MIME::Types returns "jpeg" by default, even though the preferred
    # extension is "jpg". This is fixed in later versions of the mime-types,
    # but Rails 3.x users are stuck with mime-types 1.x.
    def self.map_common(extension)
      extension == "jpeg" ? "jpg" : extension
    end
  end
end
