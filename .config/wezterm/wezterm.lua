local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

config.automatically_reload_config    = true

-- WSL:Ubuntuをデフォルトに設定
config.default_domain                 = 'WSL:Ubuntu'
-- IME　有効化
config.use_ime                        = true
-- スクロールバーを表示
config.enable_scroll_bar              = true

config.default_cursor_style           = 'BlinkingUnderline'
config.window_close_confirmation      = 'AlwaysPrompt'

config.font_size                      = 12

config.color_scheme                   = 'AdventureTime'
-- config.window_background_opacity      = 0.85

config.initial_rows                   = 28
config.initial_cols                   = 90

config.background                     = {
    {
        source = {
            Gradient = {
                colors = { "#124354", "#001522" },
                orientation = {
                    Linear = { angle = -30.0 },
                },
            },
        },
    },
    {
        source = {
            File = "C:\\Users\\kaito\\.config\\wezterm\\background.jpg"
        },
        opacity = 0.3,
        repeat_x = "NoRepeat",
        repeat_y = "NoRepeat",
    }
}

----------
-- Tab
----------
-- タイトルバーを非表示
-- config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar           = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab   = true
-- タブバーの透過
config.window_frame                   = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}
-- タブバーを背景色に合わせる
config.window_background_gradient     = {
    colors = { "#000000" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false

-- タブ同士の境界線を非表示
config.colors                         = {
    tab_bar = {
        inactive_tab_edge = "none",
    },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW                = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW               = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d74"
    local foreground = "#FFFFFF"
    local edge_background = "none"
    if tab.is_active then
        background = "#ae8b2d"
        foreground = "#FFFFFF"
    end
    local edge_foreground = background
    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
    }
end)

-- config.color_scheme = 'Materia (base16)'

return config
