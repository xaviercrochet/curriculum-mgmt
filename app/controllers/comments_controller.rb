class CommentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
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

  def show
    @comment = Comment.find(params[:id])
    @answer = Answer.new
  end

  def index
    @comments = Comment.all
    @answer = Answer.new
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update(comment_params)
    if @comment.errors.any?
      @student_program = @comment.student_program
      render action: :edit
    else
      redirect_to @comment.student_program
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    @student_program = @comment.student_program
  end

private

  def comment_params
    params.require(:comment).permit(:student_program_id, :content)
  end
end
