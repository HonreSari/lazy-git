return {
  {
    "3rd/image.nvim",
    -- This "build" command ensures the plugin is compiled for your M2 Mac
    build = "luarocks --lua-version 5.1 install magick",
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          filetypes = { "markdown", "vimwiki" },
        },
      },
      max_width = 80,
      max_height = 10,
      -- This points to where your M2 Homebrew stores things
      magick_header_path = "/opt/homebrew/include/ImageMagick-7/MagickWand/MagickWand.h",
    },
  },
}
