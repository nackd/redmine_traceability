ActionController::Routing::Routes.draw do |map|
  map.traceability '/projects/:project_id/traceability', :controller => 'mt', :action => 'index'
end
