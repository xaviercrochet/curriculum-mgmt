module JustificationsHelper
  def render_constraint(exception, student_program)
    case exception.constraint_type
    when "Prerequisite"
      render partial: 'prerequisite', locals: {exception: exception, student_program: student_program}
    when "Corequisite"
      render partial:'corequisite', locals: {exception: exception, student_program: student_program}
    when "Mandatory"
      render partial:'mandatory', locals: {exception: exception, student_program: student_program}
    when "OrCorequisite"
      render partial:'or_corequisite', locals: {exception: exception, student_program: student_program}
    when "OrPrerequisite"
      render partial:'or_prerequisite', locals: {exception: exception, student_program: student_program}
    when "XorCorequisite"
      render partial:'xor_corequisite', locals: {exception: exception, student_program: student_program}
    when "XorPrerequisite"
      render partial:'xor_prerequisite', locals: {exception: exception, student_program: student_program}
    when "Min"
      render partial:'min', locals: {exception: exception, student_program: student_program}
    when "Max"
      render partial:'max', locals: {exception: exception, student_program: student_program}
    end
  end
end