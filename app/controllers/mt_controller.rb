class MtController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize, :get_trackers
  menu_item :traceability

  def index
    @issue_rows = @tracker_rows.issues.find(:all,
                                            :include => [:relations_from => :issue_to, :relations_to => :issue_from],
                                            :order => 'id',
                                            :conditions => ['project_id=?', @project.id])
    @issue_cols = @tracker_cols.issues.find(:all,
                                            :conditions => ['project_id = ?', @project.id],
                                            :order => 'id')

    @not_seen_issue_cols = @issue_cols.clone
    @issue_pairs = {}
    @issue_rows.each do |row_issue|
      rel_issues_collection = []
      row_issue.relations_to.each do |issue_relation|
        rel_issue = issue_relation.issue_from
        if rel_issue.tracker_id == @tracker_cols.id
          rel_issues_collection << rel_issue
        end
      end

      row_issue.relations_from.each do |issue_relation|
        rel_issue = issue_relation.issue_to
        if rel_issue.tracker_id == @tracker_cols.id
          rel_issues_collection << rel_issue
        end
      end

      unless rel_issues_collection.empty?
        rel_issues_collection.each { |i| @not_seen_issue_cols.delete i }
        @issue_pairs[row_issue] ||= {}
        rel_issues_collection.each { |i| @issue_pairs[row_issue][i] = true }
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
