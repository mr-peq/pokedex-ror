class TypesController < ApplicationController
  def index
    begin
      @types = Type.all
    rescue => exception
      @errors = exception
    end

    if @errors
      render json: @errors
    else
      render json: @types
    end
  end
end
