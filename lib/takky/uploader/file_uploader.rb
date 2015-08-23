module Takky
  module Uploader
    class FileUploader < AbstractUploader
      def initialize(attachment_class, attachment_id, tempfile)
        super(attachment_class, attachment_id)
        @file = tempfile
        update_extension
      end

      private

      def update_extension
        ext = Takky::MimeType.for(filename)
        if ext != attachment.extension
          attachment.update_attributes!(extension: ext)
        end
      end

      # Handle Tempfiles and regular Files
      # TODO: Still necessary?
      def filename
        if @file.respond_to?(:original_filename)
          @file.original_filename
        else
          File.basename(@file)
        end
      end
    end
  end
end
