ARGF.each_line.grep(/add_index/) do |index_statement|
  # Skip unique indexes because the lanyrd converter preserves them
  next if index_statement.include?('unique: true')

  puts <<EOS
begin
  ActiveRecord::Base.connection.#{index_statement.strip}
  puts 'Created index ' + %q{#{index_statement.split[4]}}
rescue ArgumentError => e
  puts e
end

EOS
end
