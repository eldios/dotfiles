return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" }, -- already provided by LazyVim
  config = true,
  keys = {
    { "<leader>ai", "<cmd>ClaudeCode<cr>", desc = "Claude Code: toggle" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude Code: continue" },
    { "<leader>ay", "<cmd>ClaudeCode --resume<cr>", desc = "Claude Code: resume" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude Code: select model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude Code: add current buffer" },
    { "<leader>av", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code: send selection" },
    {
      "<leader>av",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Claude Code: add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    },
    { "<leader>aj", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: accept diff" },
    { "<leader>ak", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude Code: deny diff" },
  },
}
