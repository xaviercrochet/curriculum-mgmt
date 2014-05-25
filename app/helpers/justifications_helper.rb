module JustificationsHelper
  def render_constraint(exception, student_program, i)
    case exception.constraint_type
    when "Prerequisite"
      render partial: 'prerequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "Corequisite"
      render partial:'corequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "Mandatory"
      render partial:'mandatory', locals: {exception: exception, student_program: student_program, i:i}
    when "OrCorequisite"
      render partial:'or_corequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "OrPrerequisite"
      render partial:'or_prerequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "XorCorequisite"
      render partial:'xor_corequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "XorPrerequisite"
      render partial:'xor_prerequisite', locals: {exception: exception, student_program: student_program, i:i}
    when "Min"
      render partial:'min', locals: {exception: exception, student_program: student_program, i:i}
    when "Max"
      render partial:'max', locals: {exception: exception, student_program: student_program, i:i}
    end
  end
end