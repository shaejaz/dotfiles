local module = {
    terminal = os.getenv('TERMINAL') or 'xterm',
    editor   = os.getenv('EDITOR') or 'nano',
}

module.editor_cmd = module.terminal .. ' -e ' .. module.editor
module.manual_cmd = module.terminal .. ' -e man awesome'

return module
