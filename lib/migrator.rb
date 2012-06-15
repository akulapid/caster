require 'scope'

class Migrator

  def self.run migration
    migration.up_executions.each do |execution|
      execution.execute
    end
  end
end