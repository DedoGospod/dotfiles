return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
         'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
    },
  },
}
