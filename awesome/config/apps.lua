local module = {
    terminal = 'kitty',
    editor   = 'nvim',
}

module.editor_cmd = module.terminal .. ' -e ' .. module.editor
module.manual_cmd = module.terminal .. ' -e man awesome'

return module
