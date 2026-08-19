#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(ggplot2)
  library(jsonlite)
  library(dplyr)
  library(xkcd)
  library(showtext)
  library(patchwork)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) stop("usage: plot_download_stats.R <in.json> <out.png> <font.ttf>")
in_json <- args[1]; out_png <- args[2]; font_ttf <- args[3]

font_add("xkcd", font_ttf)
showtext_auto()
showtext_opts(dpi = 150)

BLUE <- "#2a78d6"
ORANGE <- "#eb6834"
INK <- "#52514e"

stats <- fromJSON(in_json)
d <- stats$rows

base_theme <- theme_xkcd() +
  theme(text = element_text(family = "xkcd", size = 12))

tot <- d %>%
  group_by(slug) %>%
  summarise(n = sum(downloads), .groups = "drop") %>%
  arrange(n) %>%
  as.data.frame()
tot$lab <- gsub("_", " ", tot$slug)
tot$y <- seq_len(nrow(tot))

p1 <- ggplot(tot, aes(x = n, y = y)) +
  geom_col(fill = BLUE, width = 0.55, orientation = "y") +
  geom_text(aes(label = n), hjust = -0.3, family = "xkcd", size = 4, colour = INK) +
  scale_y_continuous(breaks = tot$y, labels = tot$lab) +
  xkcdaxis(xrange = c(0, max(tot$n) * 1.28),
           yrange = c(0.4, nrow(tot) + 0.6)) +
  labs(title = "Image pulls per add-on", x = NULL, y = NULL) +
  base_theme

arch <- d %>%
  group_by(arch) %>%
  summarise(n = sum(downloads), .groups = "drop") %>%
  arrange(arch) %>%
  as.data.frame()

p2 <- ggplot(arch, aes(x = arch, y = n)) +
  geom_col(fill = c(ORANGE, BLUE)[seq_len(nrow(arch))], width = 0.5) +
  geom_text(aes(label = n), vjust = -0.7, family = "xkcd", size = 4, colour = INK) +
  xkcdaxis(xrange = c(0.5, nrow(arch) + 0.5),
           yrange = c(0, max(arch$n) * 1.25)) +
  labs(title = "Pulls by architecture", x = NULL, y = NULL) +
  base_theme

rate <- d %>%
  group_by(slug) %>%
  summarise(
    n = sum(downloads),
    months = as.numeric(difftime(as.POSIXct(stats$generated, tz = "UTC"),
                                 min(as.POSIXct(created, tz = "UTC")),
                                 units = "days")) / 30.44,
    .groups = "drop"
  ) %>%
  mutate(per_month = ifelse(months < 1, n, n / months)) %>%
  arrange(per_month) %>%
  as.data.frame()
rate$lab <- gsub("_", " ", rate$slug)
rate$y <- seq_len(nrow(rate))

p3 <- ggplot(rate, aes(x = per_month, y = y)) +
  geom_col(fill = BLUE, width = 0.55, orientation = "y") +
  geom_text(aes(label = round(per_month)), hjust = -0.35,
            family = "xkcd", size = 4, colour = INK) +
  scale_y_continuous(breaks = rate$y, labels = rate$lab) +
  xkcdaxis(xrange = c(0, max(rate$per_month) * 1.35),
           yrange = c(0.4, nrow(rate) + 0.6)) +
  labs(title = "Pulls per month available", x = NULL, y = NULL) +
  base_theme

plot <- p1 / (p3 + p2 + plot_layout(widths = c(2.4, 1))) +
  plot_annotation(
    caption = paste("GHCR image pulls as of", stats$generated),
    theme = theme(plot.caption = element_text(family = "xkcd", size = 10, colour = INK))
  )

ggsave(out_png, plot, width = 11, height = 9.5, dpi = 150, bg = "white")
cat("wrote", out_png, "\n")
