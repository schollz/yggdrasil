commands = {}

function commands.init()
  commands.classes = {}
  commands.command = c
  commands.class = ""
  commands.payload = {}
  commands:register_all()
  commands.error_prefix = "Unfound: "
end

function commands:run(c)
  self:set_command(c)
  self:clear_class()
  self:check_class()
  if self.valid_class then tracker:clear_message() end
      if self.class == "AAAA"           then -- empty to easily sort below:
  elseif self.class == "BPM"            then params:set("clock_tempo", self.payload.bpm)
  elseif self.class == "FOCUS"          then tracker:focus(self.payload.x, self.payload.y)
  elseif self.class == "PLAY"           then tracker:set_playback(true)
  elseif self.class == "SET_MIDI_NOTE"  then tracker:set_midi_note(self.payload)
  elseif self.class == "STOP"           then tracker:set_playback(false)
  else tracker:set_message(commands.error_prefix .. self.command)
  end
end

function commands:set_command(c)
  self.command = c
end

function commands:set_valid_class(bool)
  self.valid_class = bool
end

function commands:clear_class()
  self.class = ""
  self.payload = {}
end

function commands:check_class()
  self:set_valid_class(false)
  local c = fn.string_split(self.command)
  for k, check in pairs(self.classes) do
    if check.condition(c) then
      self:set_valid_class(true)
      self.class = check.name
      self.payload = check.format_payload(c)
    end
  end
end

function commands:register_class(class)
  table.insert(self.classes, class)
end

function commands:register_all()
  
  self:register_class({
    name = "BPM",
    format_payload = function(c)
      return {
        bpm = tonumber(c[2])
      }
    end,
    condition = function(c)
      return #c == 2 and c[1] == "bpm" and fn.is_int(tonumber(c[2]))
    end
  })

  self:register_class({
    name = "FOCUS",
    format_payload = function(c)
      return {
        x = tonumber(c[1]), 
        y = tonumber(c[2])
      }
    end,
    condition = function(c)
      return #c == 2 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2]))
    end
  })

  self:register_class({
    name = "PLAY",
    format_payload = function(c) return {} end,
    condition = function(c)
      return #c == 1 and c[1] == "play"
    end
  })

  self:register_class({
    name = "STOP",
    format_payload = function(c) return {} end,
    condition = function(c)
      return #c == 1 and c[1] == "stop"
    end
  })

  self:register_class({
    name = "SET_MIDI_NOTE",
    format_payload = function(c) return {
        x = tonumber(c[1]), 
        y = tonumber(c[2]),
        midi_note = tonumber(c[3])
      }
    end,
    condition = function(c)
      return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and fn.is_int(tonumber(c[3]))
    end
  })

end



return commands