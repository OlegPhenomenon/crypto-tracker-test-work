module NotificationChannelsHelper
  def channel_type_options
    [
      ['Logging', 'LogChannel'],
      ['Email', 'EmailChannel'],
      ['Telegram', 'TelegramChannel'],
    ]
  end

  def channel_type_config(channel_type)
    configs = {
      'LogChannel' => {
        name: 'Logging',
        description: 'System INFO logging',
        icon: 'log',
        color: 'gray'
      },
      'EmailChannel' => {
        name: 'Email',
        description: 'Email notifications',
        icon: 'envelope',
        color: 'blue'
      },
      'TelegramChannel' => {
        name: 'Telegram',
        description: 'Telegram notifications',
        icon: 'telegram',
        color: 'indigo'
      }
    }

    configs[channel_type] || {}
  end

  def channel_type_icon_svg(icon_type)
    icons = {
      'log' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>',
      'envelope' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>',
      'telegram' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path></svg>'
    }

    icons[icon_type] || icons['log']
  end

  def channel_type_color_classes(color)
    color_classes = {
      'gray' => {
        bg: 'bg-gray-100',
        text: 'text-gray-600'
      },
      'blue' => {
        bg: 'bg-blue-100',
        text: 'text-blue-600'
      },
      'indigo' => {
        bg: 'bg-indigo-100',
        text: 'text-indigo-600'
      },
      'green' => {
        bg: 'bg-green-100',
        text: 'text-green-600'
      }
    }

    color_classes[color] || color_classes['gray']
  end
end