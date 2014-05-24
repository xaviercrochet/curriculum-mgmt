module StudentProgramsHelper

  def render_constraints(exceptions, type)
    case type
    when "pre"
      render partial: 'student_programs/check/prerequisites', locals: {exceptions: exceptions}
    when "co"
      render partial:'student_programs/check/corequisites', locals: {exceptions: exceptions}
    when "mandatory"
      render partial:'student_programs/check/mandatories', locals: {exceptions: exceptions}
    when "or_co"
      render partial:'student_programs/check/or_corequisites', locals: {exceptions: exceptions}
    when "or_pre"
      render partial:'student_programs/check/or_prerequisites', locals: {exceptions: exceptions}
    when "xor_co"
      render partial:'student_programs/check/xor_corequisites', locals: {exceptions: exceptions}
    when "xor_pre"
      render partial:'student_programs/check/xor_prerequisites', locals: {exceptions: exceptions}
    when "min"
      render partial:'student_programs/check/min', locals: {exceptions: exceptions}
    when "max"
      render partial:'student_programs/check/max', locals: {exceptions: exceptions}
    end
  end
end
