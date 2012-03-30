class MtController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize, :get_trackers
  menu_item :traceability

  def index
    @issue_rows = @tracker_rows.issues.find(:all,
                                            :conditions => { :project_id => @project.id },
                                            :order => :id)
    @issue_cols = @tracker_cols.issues.find(:all,
                                            :conditions => { :project_id => @project.id },
                                            :order => :id)
    relations = IssueRelation.find(:all,
                                   :joins => 'INNER JOIN `issues` issue_from ON issue_from.id = `issue_relations`.issue_from_id ' +
                                             'INNER JOIN `issues` issue_to ON issue_to.id = `issue_relations`.issue_to_id ',
                                   :include => [ :issue_from, :issue_to ],
                                   :conditions => [ 'issue_from.project_id = :pid ' +
                                                    'AND issue_to.project_id = :pid ' +
                                                    'AND ((issue_from.tracker_id = :trows AND issue_to.tracker_id = :tcols) ' +
                                                         'OR (issue_from.tracker_id = :tcols AND issue_to.tracker_id = :trows))',
                                                    { :pid => @project.id, :trows => @tracker_rows.id, :tcols => @tracker_cols.id } ])

    @not_seen_issue_cols = @issue_cols.dup
    @issue_pairs = {}
    relations.each do |relation|
      if relation.issue_from.tracker_id == @tracker_rows.id
        @issue_pairs[relation.issue_from] ||= {}
        @issue_pairs[relation.issue_from][relation.issue_to] = true
        @not_seen_issue_cols.delete relation.issue_to
      else
        @issue_pairs[relation.issue_to] ||= {}
        @issue_pairs[relation.issue_to][relation.issue_from] = true
        @not_seen_issue_cols.delete relation.issue_from
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
