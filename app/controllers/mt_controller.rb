class MtController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize, :get_trackers
  menu_item :traceability

  def index
    issues = @tracker_rows.issues.find(:all,
      :conditions => ['project_id=?', @project.id],
      :order => 'id', :include => [:relations_from => :issue_to, :relations_to => :issue_from])
    @tracker_cols_issues = @tracker_cols.issues.find(:all,
      :conditions => ['project_id = ?', @project.id],
      :order => 'id')

    @tracker_cols_not_seen_issues = @tracker_cols_issues.clone
    @issue_pairs = []
    issues.each do |issue|
      rel_issues_collection = []
      issue.relations_to.each do |issue_relation|
        rel_issue = issue_relation.issue_from
        if rel_issue.tracker_id == @tracker_cols.id
          rel_issues_collection << rel_issue
        end
      end

      issue.relations_from.each do |issue_relation|
        rel_issue = issue_relation.issue_to
        if rel_issue.tracker_id == @tracker_cols.id
          rel_issues_collection << rel_issue
        end
      end

      if rel_issues_collection.empty?
        @issue_pairs << [issue, nil]
      else
        rel_issues_collection.each { |i| @tracker_cols_not_seen_issues.delete i }
        rel_issues_collection.sort! { |x, y| x.id <=> y.id }
        @issue_pairs << [issue, rel_issues_collection]
      end
    end
  end

  private

  def get_trackers
    @tracker_rows = Tracker.find(Setting.plugin_redmine_traceability['tracker0'])
    @tracker_cols = Tracker.find(Setting.plugin_redmine_traceability['tracker1'])
    @tracker_int = Tracker.first(:conditions => {:id => Setting.plugin_redmine_traceability['tracker2']})
  rescue ActiveRecord::RecordNotFound
    flash[:error] = l(:'traceability.setup')
    render
  end
end
