class Dashboard::AssigneeFilter < Dashboard::Filter

  def initialize
    super(:assignee)
  end

  def filter(issues)
    case value
    when :me   then issues.select{|i| i.children.any? or i.assigned_to_id == User.current.id }
    when :none then issues.select{|i| i.children.any? or i.assigned_to_id == nil }
    when :all  then issues
    else issues.select{|i| i.children.any? or i.assigned_to_id == value }
    end
  end

  def apply_to_child_issues?
    true
  end

  def default_values
    [ :me ]
  end

  def update(params)
    return unless assignee = params[:assignee]

    if assignee == 'all' or assignee == 'me' or assignee == 'none'
      self.value = assignee.to_sym
    else
      self.value = assignee.to_i if board.project.members.where(:id => assignee.to_i).any?
    end
  end

  def title
    case value
    when :all then I18n.t(:dashboard_all_issues)
    when :me then I18n.t(:dashboard_my_issues)
    when :none then I18n.t(:dashboard_unassigned)
    else
      values.map {|id| board.project.members.find(id) }.map(&:name).join(', ')
    end
  end

  def to_options
    [
      [[I18n.t(:dashboard_all_issues), :all],
       [I18n.t(:dashboard_my_issues), :me],
       [I18n.t(:dashboard_unassigned), :none]],
      board.project.members.map{|user| [user.name, user.id] }
    ]
  end
end
