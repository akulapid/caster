require 'scope'

class Migrator

  def self.run migration
    migration.up_scopes.each do |execution|
      execution.execute
    end
  end
end