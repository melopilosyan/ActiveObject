require 'notify-send'


module Notifier
  def self.send(summary, body, timeout, icon = :error)
    NotifySend.send summary: summary, body: body, icon: icon.to_s, timeout: timeout
  end
end
