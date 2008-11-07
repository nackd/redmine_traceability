# Redmine sample plugin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting MT plugin for Redmine'

Redmine::Plugin.register :redmine_trazabilidad do
  name 'Matriz de Trazabilidad'
  author 'Gumer Coronel'
  description 'Plugin para mostrar la matriz de trababilidad entre dos trackers'
  version '0.1.1'
  
  settings :default => {'trackers' => 'CMMI_Requisitos, CMMI_Casos de prueba'}, 
    :partial => 'settings/settings'

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
  menu :project_menu, "Trazabilidad", 
    {:controller => 'mt', :action => 'index'}, {}
end
