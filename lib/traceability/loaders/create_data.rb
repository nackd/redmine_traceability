module Traceability
  module Loaders
    module CreateData
      include Redmine::I18n

      class << self
        def load
          DEFAULT_VALUES['trackers'].each do |tracker, name|
            Tracker.create(:name => name, :is_in_chlog => true,  :is_in_roadmap => true)
          end
        end
      end
    end
  end
end
