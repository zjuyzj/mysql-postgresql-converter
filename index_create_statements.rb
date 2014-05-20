# index_create_statements.rb
#
# Parse db/schema.rb for GitLab and extract PostgreSQL `CREATE INDEX`
# statements.
#
# ruby index_create_statements.rb /home/git/gitlab/db/schema.rb
#
# This script was created to work around the fact that dbconverter.py strips
# all plain `KEY` statements from MySQL's `CREATE TABLE` statements.

# Hack to get to the block that contains the actual schema definition
module ActiveRecord
  module Schema
    def self.define(*args)
      yield
    end
  end
end

# We only want the add_index statements, so ignore everything else
def enable_extension(*args); end
def create_table(*args); end

def add_index(table_name, index_columns, options)
  index_name = options.delete(:name)
  index_using = options.delete(:using)

  # Unique indexes are already created by the lanyrd MySQL to Postgres converter
  return if options[:unique]

  # Create indexes concurrently in case the database is in production
  puts "CREATE INDEX CONCURRENTLY #{index_name} ON #{table_name} USING #{index_using} (#{index_columns.join(', ')});"
end

eval ARGF.read
