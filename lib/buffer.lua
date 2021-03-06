buffer = {}

function buffer.init()
  buffer.b = ""
  buffer.tb = {}
  buffer.history_index = 0
  buffer.history = {}
  buffer.extents = 0
end

function buffer:execute()
  self:save_history()
  self:set_history_index(0)
  runner:run(self.b)
  self:clear()
end

function buffer:add(s)
  self.b = self.b .. s
  self.tb[#self.tb + 1] = s
  self.extents = screen.text_extents(self.b)
end

function buffer:set(buffer_string, buffer_table)
  self.b = buffer_string
  self.tb = buffer_table
  self.extents = screen.text_extents(self.b)
end

function buffer:clear()
  self.b = ""
  self.tb = {}
  self.extents = 0
end

function buffer:backspace()
  self.b = self.b:sub(1, -2)
  self.tb[#self.tb] = nil
  self.extents = screen.text_extents(self.b)
end

function buffer:get_history()
  if self.history_index > 0 and #self.history > 0 then
    return self.history[self.history_index]
  end
end

function buffer:save_history()
  table.insert(self.history, 1, {
    history_string = self.b,
    history_table = self.tb
  })
end

function buffer:up_history()
  local check = self.history_index + 1
  self:set_history_index(check > #self.history and #self.history or check)
  self:history_cleanup()
end

function buffer:down_history()
  local check = self.history_index - 1
  self:set_history_index(check < 1 and 0 or check)
  self:history_cleanup()
end

function buffer:history_cleanup()
  local history = self:get_history()
  if history ~= nil then
    buffer:clear()
    buffer:set(history.history_string, history.history_table)
  else
    buffer:clear()
  end
end

function buffer:set_history_index(i)
  self.history_index = i
end

function buffer:is_empty()
  return #buffer.tb == 0
end

function buffer:get()
  return self.b
end

function buffer:get_extents()
  return self.extents
end

return buffer