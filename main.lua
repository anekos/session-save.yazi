local function trim(value)
  if not value then
    return ''
  end
  return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function join_path(base, target)
  if base == '' then
    return target
  end

  local tail = base:sub(-1)
  if tail == '/' or tail == '\\' then
    return base .. target
  end

  local sep = base:match('\\') and '\\' or '/'
  return base .. sep .. target
end

local function get_session_file()
  local session_file = os.getenv('YAZI_SESSION_FILE')
  if not session_file or session_file == '' then
    return nil, 'YAZI_SESSION_FILE is not set.'
  end
  return session_file
end

local function get_session_dir()
  local dir = os.getenv('YAZI_SESION_DIR') or os.getenv('YAZI_SESSION_DIR')
  if not dir or dir == '' then
    return nil, 'YAZI_SESION_DIR is not set.'
  end
  return dir
end

local collect_tabs = ya.sync(function()
  local entries = {}
  for i = 1, #cx.tabs do
    local tab = cx.tabs[i]
    if tab and tab.current and tab.current.cwd then
      entries[#entries + 1] = tostring(tab.current.cwd)
    end
  end
  return entries
end)

local function write_session(path, entries)
  local file, err = io.open(path, 'w')
  if not file then
    return false, string.format('Unable to open %s (%s)', path, err or 'unknown error')
  end

  for i = 1, #entries do
    file:write(entries[i] .. '\n')
  end
  file:close()
  return true
end

local function save_to(path)
  local entries = collect_tabs()
  if #entries == 0 then
    return false, 'No tabs available to persist.'
  end

  return write_session(path, entries)
end

local function auto_save()
  local session_file = get_session_file()
  if not session_file then
    return
  end

  save_to(session_file)
end

local function resolve_target(raw)
  local value = trim(raw or '')
  if value == '' then
    return nil, 'Session name cannot be empty.'
  end

  local base, err = get_session_dir()
  if not base then
    return nil, err or 'Session directory is unavailable.'
  end

  return join_path(base, value)
end

local function setup()
  ps.sub('cd', auto_save)
  ps.sub('tab', auto_save)
end

local function manual_save(_, job)
  local provided = nil
  if job and job.args and job.args[1] then
    provided = job.args[1]
  end

  if not provided or trim(provided) == '' then
    local value, event = ya.input {
      title = 'Save session as:',
      position = { 'top-center', y = 4, w = 40 },
    }

    if event == 1 then
      provided = value
    else
      return
    end
  end

  local target, err = resolve_target(provided)
  if not target then
    ya.notify {
      title = 'Session Save',
      content = err or 'Invalid session name.',
      level = 'error',
      timeout = 5,
    }
    return
  end

  local ok, reason = save_to(target)
  if ok then
    ya.notify {
      title = 'Session Save',
      content = string.format('Saved session to %s', target),
      timeout = 3,
    }
  else
    ya.notify {
      title = 'Session Save',
      content = reason or 'Unable to save session.',
      level = 'error',
      timeout = 5,
    }
  end
end

return {
  setup = setup,
  entry = manual_save,
}
