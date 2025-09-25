module Listeners
  class ListenerInterface
    def run
      raise NotImplementedError, "#{self.class.name} must implement :run"
    end
  end
end
