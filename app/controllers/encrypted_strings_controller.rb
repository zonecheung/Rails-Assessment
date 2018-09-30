class EncryptedStringsController < ApplicationController
  before_action :load_encrypted_string, only: [:show, :destroy]

  def create
    encrypted_string = EncryptedString.new(encrypted_string_params)

    if encrypted_string.save
      render json: { token: encrypted_string.token }
    else
      render json: { message: encrypted_string.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def show
    render json: { value: @encrypted_string.value }
  end

  def destroy
    # NOTE: Previously we assume that .destroy! will always be successful,
    # =>    but it's also possible to add before_destroy callback, set the
    # =>    errors, and throw(:abort) to cancel the destroy,
    # =>    see: https://stackoverflow.com/questions/38625276/rails-5-throw-abort-how-do-i-setup-error-messages
    if @encrypted_string.destroy
      head :ok
    else
      render json: { message: @encrypted_string.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  private

  def load_encrypted_string
    @encrypted_string = EncryptedString.find_by(token: params[:token])
    if @encrypted_string.nil?
      render json: { messsage: "No entry found for token #{params[:token]}" },
             status: :not_found
    end
  end

  def encrypted_string_params
    params.require(:encrypted_string).permit(:value)
  end
end
