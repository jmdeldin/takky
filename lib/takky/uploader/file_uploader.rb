module Takky
  module Uploader
    class FileUploader < AbstractUploader
      def initialize(attachment_class, attachment_id, tempfile)
        super(attachment_class, attachment_id)
        @file = tempfile
        update_extension
      end

      def update_extension
        ext = Takky::MimeType.for(@file.original_filename)
        if ext != attachment.extension
          attachment.update_attributes!(extension: ext)
        end
      end
    end
  end
end
