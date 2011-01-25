class MtController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :get_trackers
  menu_item :traceability

  def index
    issues = @tracker0.issues.find(:all,
      :conditions => ['project_id=?', @project.id],
      :order => 'id')

    @issue_pairs = tracker1_seen_issues = []
    issues.each do |issue|
      rel_issues_collection = []
      issue.relations_to.each do |issue_relation|
        rel_issue = issue_relation.issue_from
        if rel_issue.tracker == @tracker1
          rel_issues_collection << rel_issue
        end
      end

      issue.relations_from.each do |issue_relation|
        rel_issue = issue_relation.issue_to
        if rel_issue.tracker == @tracker1
          rel_issues_collection << rel_issue
        end
      end

      if rel_issues_collection.empty?
        @issue_pairs << [issue, nil]
      else
        tracker1_seen_issues |= rel_issues_collection
        rel_issues_collection.sort! { |x, y| x.id <=> y.id }
        @issue_pairs << [issue, rel_issues_collection]
      end
    end

    @tracker1_issues = @tracker1.issues.find(:all,
      :conditions => ['project_id = ?', @project.id],
      :order => 'id')
    @tracker1_not_seen_issues = @tracker1_issues - tracker1_seen_issues
  end

  private
  def find_project
    @project = Project.find(params[:id])
  end

  def get_trackers
    @tracker0 = Tracker.find(Setting.plugin_redmine_traceability['tracker0'])
    @tracker1 = Tracker.find(Setting.plugin_redmine_traceability['tracker1'])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = l(:'traceability.setup')
    render
  end
end
