# frozen_string_literal: true

class EmailSmtpSettingsController < ApplicationController
  before_action :authorize_admin
  authorize_resource :encrypted_config, only: :index
  authorize_resource :encrypted_config, parent: false, only: :create

  def index; end

  def create
    if @encrypted_config.update(email_configs)
      unless Docuseal.multitenant?
        SettingsMailer.smtp_successful_setup(@encrypted_config.value['from_email'] || current_user.email).deliver_now!
      end

      redirect_to settings_email_index_path, notice: I18n.t('changes_have_been_saved')
    else
      render :index, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash[:alert] = e.message

    render :index, status: :unprocessable_entity
  end

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
      EncryptedConfig.find_or_initialize_by(account: current_account, key: EncryptedConfig::EMAIL_SMTP_KEY)
  end

  def email_configs
    params.require(:encrypted_config).permit(value: {}).tap do |e|
      e[:value].compact_blank!
    end
  end
end
