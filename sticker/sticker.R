library(tidyverse)
library(cowplot)
scale <- 1
dx <- 1
dy <- sqrt(2)
corner <- 1/3
git_colour <- "#c04384"
icon <- tribble(
  ~x, ~y,
  0, 0,
  dx, 0,
  dx, dy - corner * dx,
  dx - corner * dx, dy - corner * dx,
  dx - corner * dx, dy,
  dx, dy - corner * dx,
  dx - corner * dx, dy,
  0, dy,
  0, 0,
  dx, 0
) %>%
  ggplot(aes(x = x, y = y)) +
  geom_path(colour = git_colour, size = 1, linejoin = "round") +
  coord_fixed() +
  annotate(
    "text", label = "TXT", colour = git_colour,
    x = dx / 2, y = dy / 3, hjust = 0.5, vjust = 0.5,
    size = 5 * scale, family = "Flanders Art Sans"
  ) +
  theme_void()
meta <- tribble(
  ~x, ~y,
  0, 0,
  dx, 0,
  dx, dy - corner * dx,
  dx - corner * dx, dy - corner * dx,
  dx - corner * dx, dy,
  dx, dy - corner * dx,
  dx - corner * dx, dy,
  0, dy,
  0, 0,
  dx, 0
) %>%
  ggplot(aes(x = x, y = y)) +
  geom_path(colour = git_colour, size = 1, linejoin = "round") +
  coord_fixed() +
  annotate(
    "text", label = "meta", colour = git_colour,
    x = dx / 2, y = dy / 3, hjust = 0.5, vjust = 0.5,
    size = 5 * scale, family = "Flanders Art Sans"
  ) +
  theme_void()
hexagon <- tibble(
  angle = seq(0, 2, length = 7) * pi + pi / 2,
  range = 1
) %>%
  mutate(
    x = range * cos(angle),
    y = range * sin(angle)
  ) %>%
  ggplot(aes(x = x, y = y)) +
  geom_polygon(fill = NA, colour = git_colour, size = 3) +
  coord_fixed() +
  theme_void()

df <- crossing(
  x = 1:5,
  y = 0:-8
) %>%
  mutate(
    x2 = x + 1,
    y2 = y - 1,
    fill = ifelse(y == 0, "row", NA)
  ) %>%
  ggplot(aes(xmin = x, ymin = y, xmax = x2, ymax = y2, fill = fill)) +
  geom_rect(colour = git_colour) +
  scale_discrete_manual(
    values = git_colour, na.value = NA, guide = "none", aesthetics = "fill"
  ) +
  coord_fixed(1/2) +
  theme_void()
sticker <- ggdraw() +
  draw_plot(hexagon) +
  draw_label(
    "git2rdata", x = 0.5, y = 0.8,
    colour = git_colour, fontfamily = "Flanders Art Sans", size = 20 * scale
  ) +
  draw_plot(df, x = -0.27, scale = 0.3) +
  draw_label(
    "\u21C4", colour = git_colour, fontfamily = "Flanders Art Sans",
    size = 40 * scale
  ) +
  draw_image("git.png", x = 0.25, y = -0.18, scale = 0.25) +
  draw_label(
    "+", colour = git_colour, fontfamily = "Flanders Art Sans",
    size = 40 * scale, x = 0.75
  ) +
  draw_plot(meta, x = 0.35, y = 0.15, scale = 0.2) +
  draw_plot(icon, x = 0.15, y = 0.15, scale = 0.2)
save_plot(
  filename = "../man/figures/logo.png",
  sticker,
  base_height = scale * 278 / 72,
  base_width = scale * 240 / 72,
  dpi = 72,
  bg = NA
)
