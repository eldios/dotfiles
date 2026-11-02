return {
  "saghen/blink.cmp",
  lazy = false, -- ensure it loads early
  -- version = "v0.*", -- use the latest stable version
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    -- Disable cmdline completion entirely to prevent slash command interference
    cmdline = {
      enabled = true,
      completion = {
        menu = {
          auto_show = false
        },
        ghost_text = {
          enabled = true
        },
      },
    },

    -- Configure trigger settings to be less aggressive
    trigger = {
      completion = {
        -- Disable completion on trigger characters like "/"
        show_on_insert_on_trigger_character = false,
      },
    },

    signature = { enabled = true },

    completion = {
      menu = {
        auto_show = false,
        enabled = true,
      },
    },

  },
}
