local util = {}

local tmux_directions = { ['p'] = 'l', ['h'] = 'L', ['j'] = 'D', ['k'] = 'U', ['l'] = 'R', ['n'] = 't:.+' }

-- send the tmux command to the server running on the socket
-- given by the environment variable $TMUX
--
-- the check if tmux is actually running (so the variable $TMUX is
-- not nil) is made before actually calling this function
local function tmux_command(args)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ',')[1]
    local command = {
      "tmux",
      "-S",
      tmux_socket,
    };

    -- Concat args into command
    for _, v in ipairs(args) do
        table.insert(command, v)
    end

    return vim.fn.system(command)
end

-- check whether the current tmux pane is zoomed
local function is_tmux_pane_zoomed()
    local zoomed_value = tmux_command({
        "display-message",
        "-p",
        "#{window_zoomed_flag}",
    }):gsub("%s+", "") -- the output of the tmux command is "1\n", so we strip that away

    if zoomed_value == "1" then
      return true
    end

    return false
end

-- whether tmux should take control over the navigation
function util.should_tmux_control(is_same_winnr, disable_nav_when_zoomed)
    if is_tmux_pane_zoomed() and disable_nav_when_zoomed then
        return false
    end
    return is_same_winnr
end

-- change the current pane according to direction
function util.tmux_change_pane(direction)
    local pane_id = vim.env.TMUX_PANE;

    tmux_command({
        "select-pane",
        "-t",
        pane_id,
        "-" .. tmux_directions[direction],
    })
end

-- capitalization util, only capitalizes the first character of the whole word
function util.capitalize(str)
    local capitalized = str:gsub("(%a)(%a+)", function(a, b)
        return string.upper(a) .. string.lower(b)
    end)

    return capitalized:gsub("_", "")
end

return util
