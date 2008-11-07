# Sample plugin controller
class MtController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project, :authorize, :get_trackers

  helper :sort
  include SortHelper
  helper :issues

  
  def index
    issues = @tracker_0.issues.find(:all, 
      :conditions => ['project_id=?', @project.id])
    
    @issue_pairs = []
    issues.each do |issue|
      rel_issues_collection = []
      issue.relations_to.each do |issue_relation|
        rel_issue = issue_relation.issue_from
        if rel_issue.tracker == @tracker_1
          rel_issues_collection << rel_issue
        end
      end
      
      issue.relations_from.each do |issue_relation|
        rel_issue = issue_relation.issue_to
        if rel_issue.tracker == @tracker_1
          rel_issues_collection << rel_issue
        end
      end
      
      if rel_issues_collection.empty?
        @issue_pairs << [issue, nil]
      else
        @issue_pairs << [issue, rel_issues_collection]
      end
    end
  end


  private
  def find_project
    @project = Project.find(params[:id])
  end
  
  def get_trackers
    # Para acceder al valor de los trackers
    @trackers_names = Setting.plugin_redmine_trazabilidad['trackers'].split(',')
    
    @tracker_0 = Tracker.find_by_name(@trackers_names[0].strip)
    @tracker_1 = Tracker.find_by_name(@trackers_names[1].strip)
  end
end
