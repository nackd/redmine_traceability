require 'redmine'

Rails.configuration.after_initialize do
  I18n.with_locale(Setting.default_language) do
    Redmine::Plugin.register :redmine_traceability do
      name I18n.t :'traceability.plugin_name'
      description I18n.t :'traceability.plugin_description'
      author 'Emergya'
      version '1.0'

      settings :default => {'tracker0' => nil, 'tracker1' => nil},
      :partial => 'settings/traceability'

      # This plugin adds a project module
      # It can be enabled/disabled at project level (Project settings -> Modules)
      project_module :traceability do
        # This permission has to be explicitly given
        # It will be listed on the permissions screen
        permission :view_mt, {:mt => [:index]}
      end

      # A new item is added to the project menu
      menu :project_menu, :traceability,
      {:controller => 'mt', :action => 'index'},
      :caption => :'traceability.menu_item_name',
      :param => :project_id
    end
  end
end
