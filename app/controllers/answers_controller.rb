class AnswersController < ApplicationController
  def create
    @answer = Answer.new
    @answer.content = params[:answer][:content]
    @answer.user = current_user
    @comment = Comment.find(params[:comment_id])
    @comment.read = true
    @comment.save
    @answer.comment = @comment
    @answer.save
    redirect_to comments_path
  end

private
  def answer_params
    params.require(:answer).permit(:user_id, :comment_id, :content)
  end

end
