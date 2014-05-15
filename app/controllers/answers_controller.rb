class AnswersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  def create
    @answer = Answer.new
    @answer.content = params[:answer][:content]
    @answer.user = current_user
    @comment = Comment.find(params[:comment_id])
    @comment.tag_as_read(current_user)
    @answer.comment = @comment
    @answer.save
    redirect_to :back
  end

private
  def answer_params
    params.require(:answer).permit(:user_id, :comment_id, :content)
  end

end
