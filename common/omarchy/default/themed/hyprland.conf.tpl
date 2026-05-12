general {
  col.active_border = rgba({{ accent_strip }}aa)
  col.inactive_border = rgba({{ foreground_strip }}44)
}

group {
  col.border_active = rgba({{ accent_strip }}aa)
  col.border_inactive = rgba({{ foreground_strip }}44)

  groupbar {
    text_color = rgb({{ foreground_strip }})
    text_color_inactive = rgba({{ foreground_strip }}88)
    col.active = rgba({{ accent_strip }}55)
    col.inactive = rgba({{ background_strip }}88)
  }
}

decoration {
  shadow {
    color = rgba(00000066)
  }
}
