class JustificationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  def new
    @student_program = StudentProgram.find(params[:student_program_id])
    @justification = @student_program.build_justification
  end

  def create
    @student_program = StudentProgram.find(params[:student_program_id])
    @justification = @student_program.create_justification(justification_params)
    if @justification.errors.any?
      render action: :new
    else
      redirect_to @student_program
    end
  end

  def show
    @justification = Justification.find(params[:id])
    @answer = Answer.new
  end

  def index
    @justifications = Justification.all
    @answer = Answer.new
  end

  def update
    @justification = Justification.find(params[:id])
    @justification.update(justification_params)
    if @justification.errors.any?
      @student_program = @justification.student_program
      render action: :edit
    else
      redirect_to @justification.student_program
    end
  end

  def edit
    @justification = Justification.find(params[:id])
    @student_program = @justification.student_program
  end

private

  def justification_params
    params.require(:justification).permit(:student_program_id, :content)
  end
end
