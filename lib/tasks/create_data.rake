desc 'Load Traceability needed data (trackers)'

namespace :traceability do
  task :create_data => :environment do
    begin
      Traceability::Loaders::CreateData.load
      puts 'Default traceability configuration data loaded.'
    rescue => error
      puts "Error: #{error}"
      puts 'Default traceability configuration data was not loaded.'
    end
  end
end
