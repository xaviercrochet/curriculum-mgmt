module StudentProgramsHelper

  def render_constraints(exceptions, type, student_program)
    case type
    when "pre"
      render partial: 'student_programs/check/prerequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "co"
      render partial:'student_programs/check/corequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "mandatory"
      render partial:'student_programs/check/mandatories', locals: {exceptions: exceptions, student_program: student_program}
    when "or_co"
      render partial:'student_programs/check/or_corequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "or_pre"
      render partial:'student_programs/check/or_prerequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "xor_co"
      render partial:'student_programs/check/xor_corequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "xor_pre"
      render partial:'student_programs/check/xor_prerequisites', locals: {exceptions: exceptions, student_program: student_program}
    when "min"
      render partial:'student_programs/check/min', locals: {exceptions: exceptions, student_program: student_program}
    when "max"
      render partial:'student_programs/check/max', locals: {exceptions: exceptions, student_program: student_program}
    end
  end
end
