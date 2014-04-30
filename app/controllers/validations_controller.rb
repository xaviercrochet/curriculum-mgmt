class ValidationsController < ApplicationController
  def index
    @validations = Validation.all
    record_history
  end

  def show
    @validation = Validation.find(params[:validation_id])
  end

  def destroy
    @validation = Validation.find(params[:id])
    @validation.destroy
    redirect_to validations_path
  end

  def validate
    @validation = Validation.find(params[:validation_id])
    @validation.student_program.validate
    @validation.destroy
    redirect_to validations_path
  end

private
  def record_history
    session[:history] ||= []
    session[:history].push request.url
    session[:history] = session[:history].last(10)
  end

  def back
    session[:history].pop
  end
end
