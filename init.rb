Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
  Kernel.load(initializer)
end
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting Traceability plugin for Redmine'

Redmine::Plugin.register :redmine_traceability do
  name :'traceability.project_module_traceability'
  author 'Emergya Consultoría'
  description :'traceability.plugin_description'
  version '0.1.1'
  
  settings :default => {}

  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :trazabilidad do
    # This permission has to be explicitly given
    # It will be listed on the permissions screen
    permission :view_mt, {:mt => [:index]}
  end
  
  permission :view_projects, 
      {:projects => [:list, :index, :show, :activity],
      :welcome => :index
      }

  # A new item is added to the project menu (because Redmine can't add it anywhere else)
  menu :project_menu, :traceability,
    {:controller => 'mt', :action => 'index'}, :caption => :'traceability.name'
end
