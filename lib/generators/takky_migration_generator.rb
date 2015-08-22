require "rails/generators/active_record/migration"

class TakkyMigrationGenerator < Rails::Generators::Base
  include ActiveRecord::Generators::Migration

  desc "Generate a migration for a table to store attachments in"
  argument :model_name, default: "Attachment", type: :string

  # needed to find the template
  def self.source_root
    __dir__
  end

  desc "Create a migration file for a new Takky model"
  def create_model_migration
    mig_name = "db/migrate/create_takky_#{model_name.downcase}.rb"
    migration_template("takky_migration.rb.erb", mig_name)
  end
end
