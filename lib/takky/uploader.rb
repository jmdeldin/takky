module Takky
  module Uploader
    autoload :AbstractUploader, "takky/uploader/abstract_uploader"
    autoload :DataUriUploader, "takky/uploader/data_uri_uploader"
    autoload :FileUploader, "takky/uploader/file_uploader"
  end
end
