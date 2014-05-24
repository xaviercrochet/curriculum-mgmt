module JustificationsHelper
  def render_constraint(exception)
    case exception.constraint_type
    when "Prerequisite"
      render partial: 'prerequisite', locals: {exception: exception}
    when "Corequisite"
      render partial:'corequisite', locals: {exception: exception}
    when "Mandatory"
      render partial:'mandatorie', locals: {exception: exception}
    when "OrCorequisite"
      render partial:'or_corequisite', locals: {exception: exception}
    when "OrPrerequisite"
      render partial:'or_prerequisite', locals: {exception: exception}
    when "XorCorequisite"
      render partial:'xor_corequisite', locals: {exception: exception}
    when "XorPrerequisite"
      render partial:'xor_prerequisite', locals: {exception: exception}
    when "Min"
      render partial:'min', locals: {exception: exception}
    when "Max"
      render partial:'max', locals: {exception: exception}
    end
  end
end