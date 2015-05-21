module ApplicationHelper
  BOOTSTRAP_FLASH_MSG = {
      'success' => 'alert-success',
      'errors' => 'alert-error',
      'error' => 'alert-error',
      'alert' => 'alert-block',
      'notice' => 'alert-info'
  }

  def bootstrap_icon_for flash_type
    { success: "ok-circle", error: "remove-circle", alert: "warning-sign", notice: "exclamation-sign" }[flash_type] || "question-sign"
  end

  def bootstrap_class_for(flash_type)
    BOOTSTRAP_FLASH_MSG.fetch(flash_type.to_s)
  end
end
