class CommentsController < ApplicationController
  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @comment = @student_program.build_comment
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @comment = @student_program.create_comment(comment_params)
    if @comment.errors.any?
      render action: :new
    else
      redirect_to @student_program
    end
  end

private

  def comment_params
    params.require(:comment).permit(:student_program_id, :content)
  end
end
