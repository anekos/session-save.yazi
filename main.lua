local function save_session()
  local session_file = os.getenv('YAZI_SESSION_FILE')

  if not session_file or session_file == '' then
    return
  end

  local file = io.open(session_file, 'w')
  if file then
    for i = 1, #cx.tabs do
      local tab = cx.tabs[i]
      if tab and tab.current and tab.current.cwd then
        file:write(tostring(tab.current.cwd) .. '\n')
      end
    end
    file:close()
  end
end

local function setup()
  ps.sub('cd', save_session)
  ps.sub('tab', save_session)
end

return { setup = setup }
