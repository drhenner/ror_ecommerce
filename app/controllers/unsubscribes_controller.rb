class UnsubscribesController < ApplicationController
  def show
    UsersNewsletter.unsubscribe(params[:email], params[:key])
  end
end
