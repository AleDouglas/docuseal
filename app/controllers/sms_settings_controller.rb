# frozen_string_literal: true

class SmsSettingsController < ApplicationController
  before_action :authorize_admin
  authorize_resource :encrypted_config, only: :index
  authorize_resource :encrypted_config, parent: false, except: :index

  def index; end

  private

  def authorize_admin
    if current_user&.role == User::ADMIN_ROLE
      load_encrypted_config
    else
      render file: Rails.root.join('public/403.html'),
            status: :forbidden,
            layout: false
    end
  end

  def load_encrypted_config
    @encrypted_config =
      EncryptedConfig.find_or_initialize_by(account: current_account, key: 'sms_configs')
  end
end
