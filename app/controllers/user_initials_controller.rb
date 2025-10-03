# frozen_string_literal: true

class UserInitialsController < ApplicationController
  before_action :authorize_admin
  authorize_resource :user_config

  def edit; end

  def update
    file = params[:file]

    return redirect_to settings_profile_index_path, notice: I18n.t('unable_to_save_initials') if file.blank?

    blob = ActiveStorage::Blob.create_and_upload!(io: file.open,
                                                  filename: file.original_filename,
                                                  content_type: file.content_type)

    attachment = ActiveStorage::Attachment.create!(
      blob:,
      name: 'initials',
      record: current_user
    )

    if @user_config.update(value: attachment.uuid)
      redirect_to settings_profile_index_path, notice: I18n.t('initials_has_been_saved')
    else
      redirect_to settings_profile_index_path, notice: I18n.t('unable_to_save_initials')
    end
  end

  def destroy
    @user_config.destroy

    redirect_to settings_profile_index_path, notice: I18n.t('initials_has_been_removed')
  end

  private

  def authorize_admin
    if current_user&.role == User::ADMIN_ROLE
      load_user_config
    else
      render file: Rails.root.join('public/403.html'),
            status: :forbidden,
            layout: false
    end
  end

  def load_user_config
    @user_config =
      UserConfig.find_or_initialize_by(user: current_user, key: UserConfig::INITIALS_KEY)
  end
end
