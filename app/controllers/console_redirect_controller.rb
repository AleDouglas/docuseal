# frozen_string_literal: true

class ConsoleRedirectController < ApplicationController

  def index
    render file: Rails.root.join('public/403.html'), status: :forbidden, layout: false
  end


  private

    def authorize_admin
      render file: Rails.root.join('public/403.html'),
            status: :forbidden,
            layout: false
  end

end
