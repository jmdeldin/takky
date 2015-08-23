require "active_support/concern"

module Takky
  module Model
    extend ActiveSupport::Concern

    included do
      # Optionally in your model:
      #
      # attr_accessible :style, :extension, :file
      attr_reader :file

      validates :style, presence: true
      validates :extension, presence: true, length: {maximum: 4}

      before_save do
        set_environment
        set_uploaded_flags
        true
      end

      before_destroy :delete_uploads
    end

    def style=(s)
      self[:style] = s.to_s.strip if s.present?
    end

    def filename
      return if digest.blank?

      digest + "." + extension
    end

    def uploaded!
      self.uploaded_at = DateTime.current
      save!
    end

    def uploaded?
      uploaded_at.present?
    end

    def path
      return if new_record?
      Takky::Path.new(self)
    end

    def url(cdn: true, protocol: nil)
      return nil if new_record?
      u = Takky::Url.new(self)
      u.to_s(cdn: cdn, protocol: protocol)
    end

    def delete_uploads
      Takky::DeleteWorker.perform_async(path.root.to_s, true) if uploaded?
    end

    private

    def set_uploaded_flags
      return nil if @file.blank? || new_record?
      self.uploaded_at = nil
    end

    def set_environment
      self.environment = ENV.fetch('RACK_ENV', 'development')[0]
    end
  end
end
