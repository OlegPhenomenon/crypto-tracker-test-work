module WorkspacesHelper
  def colorize(color)
    if color
      "bg-#{color}-100 text-#{color}-600 group-hover:bg-#{color}-200"
    else
      "bg-gray-100 text-gray-600 group-hover:bg-gray-200"
    end
  end
end
