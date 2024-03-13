# NOTE: working directory must be set to the highest level of the repository

# clean the environment
rm(list = ls())

# load required packages
library(tidyverse)
library(janitor)
library(ggpubr)
library(sf)
library(readxl)
library(rnaturalearth)
library(patchwork)

# load the data
df <- read_csv(file.path("data", "240219 TXF_data_all_energy_only.csv"), guess_max = 17000) %>%
  
  # set "" in character columns to NA
  mutate_if(is.character, ~ if_else(.x == "", NA_character_, .x)) %>%
  
  # consolidate the flags indicating fossils, RETs, and other energy into one character column
  mutate(ff_re_other = case_when(ff == 1 ~ "Fossil",
                                 re == 1 ~ "Renewables",
                                 other != 0 ~ "Other energy",
                                 TRUE ~ "INSPECT XX"))

# set ggplot2 theme
theme_set(theme_classic())


################################################################################
################ FIGURE ON GEOGRAPHIC IMPLICATIONS #############################
################################################################################

# define color scales for the maps and bar charts (taken from IPCC style guides)
palette_ipcc_highcontrast_4col <-  c(rgb(237, 248, 251, maxColorValue = 255),
                                     rgb(179, 205, 227, maxColorValue = 255),
                                     rgb(140, 150, 198, maxColorValue = 255),
                                     rgb(136, 65, 157, maxColorValue = 255))

palette_ipcc_temp_4col <- c(rgb(  244, 165, 130, maxColorValue = 255),
                            rgb( 253, 219, 199, maxColorValue = 255),
                            rgb(  209, 229, 240 , maxColorValue = 255),
                            rgb(  146, 197, 222 , maxColorValue = 255))


# set overall figure font size
fontsize_general <- 6

# load iso3 code for country names in TXF data
df_dealcountry_iso3_matched <- read_csv("data/txf_countrynames_iso3_matched.csv")

# merge into df for deal country and ECA country
df <- df %>%
  
  # merge in ISO3 for deal countries
  left_join(df_dealcountry_iso3_matched %>% select(dealcountry = "txf_country_name",
                                                              dealcountry_iso3 = "iso3"),
                       by = "dealcountry") %>%
  
  # merge in ISO3 for ECA countries
  left_join(df_dealcountry_iso3_matched %>% select(ecacountry = "txf_country_name",
                                                   ecacountry_iso3 = "iso3"),
            by = "ecacountry")

# check for missing ISO3 codes
if((df %>% filter(is.na(dealcountry_iso3)) %>% nrow()) != 0) stop("Data contains rows with no matching dealcountry ISO3 code. Please inspect")

# load WB classification
df_wbcountrygroups <- read_excel("data/240219 WB Country and Lending Groups.xlsx", sheet = "List of economies")

# drop the TXF country groups by income level (which are outdated for a few countries)
df <- df %>% select(-wbcountryclassification)

# merge in the most recent WB classification
df <- df %>% left_join(df_wbcountrygroups %>% rename(wbcountryclassification_udpated = "Income group"), by = c("dealcountry_iso3" = "Code"))

# collapse cumulative ECA commitment by country and FF/RE
df_map <- df %>% 
  
  # subset to FF or RE
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # collapse ECA commitments
  group_by(ff_re_other, dealcountry_iso3) %>%
  summarise(ecainvolvementonthedealin = sum(ecainvolvementonthedealin), .groups = "drop")

# load country-level shapefiles for the world from the `rnaturalearth` package
world <- rnaturalearth::ne_countries(scale = 50, returnclass = "sf") %>%
  
  # rename the ISO3 column to match the column name in the TXF data
  rename(iso3 = "adm0_a3")

# ensure that we have all relevant countries in the world shapefile
mean(df$dealcountry_iso3 %in% world$iso3)
mean(df$ecacountry_iso3[!is.na(df$ecacountry_iso3)] %in% world$iso3)

# write a function to create the map of recipient country shares in ECA financing
make_ecashare_map <- function(data = NULL, # the data to be plotted
                              fossil_or_renewables = "Fossil" # set to 'Fossil' or 'Renewables'
                              ) {
  
  world %>% 
    
    # discard Antarctica from the shapefile for visual reasons
    filter(!str_detect(admin, "Antarctica")) %>%
    
    # merge in the actual data with ECA commitments and filter to Fossil/Renewables based on fossil_or_renewables
    left_join(data %>% filter(ff_re_other == fossil_or_renewables), by = c("iso3" = "dealcountry_iso3")) %>%

    # calculate share (NOTE: we need na.rm = T because countries w/o any involvement get NA in the merging above)
    mutate(share = ecainvolvementonthedealin/sum(ecainvolvementonthedealin, na.rm = T)) %>%
    
    # create a binning variable for the continuous share variable
    mutate(share_group = case_when(is.na(share) ~ NA_character_,
                                   share < 0.01 ~ "(0%, 1%]",
                                   share < 0.025 ~ "(1%, 2.5%]",
                                   share < 0.05 ~ "(2.5%, 5%]",
                                   TRUE ~ "[5%, 15%]"
    )) %>%
    
    # plot the map with all countries in grey
    ggplot() + geom_sf(fill = "grey") +
    
    # plot another map on top with the fill color based on the binned share variable (= overlays the grey for all non-NA countries)
    geom_sf(aes(fill = share_group)) +
    
    # set the fill color scale
    scale_fill_manual(values = c(palette_ipcc_highcontrast_4col),
                      na.translate = F,
                      na.value = "grey") +
    
    # set labels
    labs(fill = "Recipient share in 2013-2023\nECA commitments (all instruments)") +
    
    # create a facet for Fossil/Renewables (NOTE: the data contains only one of them, so this simply adds a facet-style title)
    facet_wrap(~ ifelse(fossil_or_renewables == "Fossil", "Fossil", "Renewables")) +
    
    # stretch the fill legend over two rows and suppress the color in its visual elements
    guides(fill = guide_legend(nrow = 2, override.aes = list(color = NA))) +
    
    # set the color for the facet title and other axes/legend elements
    theme(strip.background = element_rect(fill = ifelse(fossil_or_renewables == "Fossil",
                                                        "lightgrey",
                                                        "#b8d3be"),
                                          color = NA),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = "bottom",
          strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt")),
          legend.text = element_text(size = fontsize_general),
          legend.title = element_text(size = fontsize_general),
          legend.margin = margin(0, 0, 0, 0, "pt"),
          legend.key.size = unit(10,"pt"))
}

# create map for fossil and renewable projects
panel1 <- ggarrange(make_ecashare_map(df_map, "Fossil"),
                    make_ecashare_map(df_map, "Renewables"),
                    align = "hv",
                    common.legend = T, legend = "bottom",
                    ncol = 2,
                    labels = c("a", ""),
                    font.label = list(size = fontsize_general + 2, color = "black", face = "bold")
)

# inspect
panel1

# collapse commitments by ECA country by domestic/same region/other region and FF/RE
df_countryfigure <- df %>%
  
  # label activities as domestic, same-region of other region
  mutate(domestic_activity = case_when(dealcountry == ecacountry ~ "Same country",
                                       dealregion == ecaregion ~ "Same region",
                                       TRUE ~ "Other region")) %>%
  
  # collapse by ECA country, domestic/same region/other region and FF/RE
  group_by(ecacountry, domestic_activity, ff_re_other) %>% summarise(y_var = sum(ecainvolvementonthedealin)) %>% ungroup() %>%
  
  # calculate total for each ECA country and FF/RE
  group_by(ecacountry, ff_re_other) %>% mutate(total = sum(y_var)) %>% ungroup()

## identify top 10 countries for FF and RE
# FF
top10_ecacountry_ff <- df_countryfigure %>% filter(ff_re_other == "Fossil") %>% select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_ff = 1:n())
# RE
top10_ecacountry_re <- df_countryfigure %>% filter(ff_re_other == "Renewables") %>% select(ff_re_other, ecacountry, total) %>% distinct() %>%
  slice_max(total, n = 10) %>%
  arrange(desc(total)) %>% mutate(rank_re = 1:n())

# merge in top10 status and collapse countries that are not in top 10 into "Other countries"
df_countryfigure_final <- df_countryfigure %>%
  
  # subset to fossil/RE deals
  filter(ff_re_other %in% c("Fossil", "Renewables")) %>%
  
  # join in top-10 status for FF
  left_join(top10_ecacountry_ff %>% select(ff_re_other, ecacountry, rank_ff), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # and for RE
  left_join(top10_ecacountry_re %>% select(ff_re_other, ecacountry, rank_re), 
            by = c("ff_re_other", "ecacountry")) %>%
  
  # create a rank variable (if not in top 10, rank = 11)
  mutate(rank = case_when(!is.na(rank_ff) ~ rank_ff,
                          !is.na(rank_re) ~ rank_re,
                          TRUE ~ 11)) %>%
  
  # collapse the commitments for countries not in the top 10
  mutate(ecacountry_grouped = if_else(rank < 11, ecacountry, "Other countries")) %>%
  group_by(ecacountry_grouped, domestic_activity, ff_re_other, rank) %>%
  summarise(y_var = sum(y_var), .groups = "drop") %>%
  mutate(domestic_activity = factor(domestic_activity, 
                                    levels = c("Same country", "Same region", "Other region")))

# create the panel for FF
ff_panel <- df_countryfigure_final %>% filter(ff_re_other == "Fossil") %>%
  
  # order countries by rank and convert commitments to billion USD
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var/10^3)) +
  
  # bar chart with stacked bars for domestic/same region/other region
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  # label axes and fill legend manually
  labs(x = "ECA country",
       y = "2013-2023 commitment\n(All instruments, USD2020 billion)", fill = "Deals located in in...") +
  
  # create a facet for fossil and renewable projects (NOTE: we have subsetted to fossil projects here, so this merely creates a facet title)
  facet_wrap(~ff_re_other, scales = "free") +
  
  # set theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
                                    face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "lightgrey",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt"))) +
  
  # flip axes and set y-axis lower limit to zero
  coord_flip(ylim = c(0, NA)) +
  
  # set style of fill legend manually
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# make the same panel for RE 
re_panel <- df_countryfigure_final %>% filter(ff_re_other == "Renewables") %>%
  
  ggplot(aes(reorder(ecacountry_grouped, -rank), y_var/10^3)) +
  
  geom_col(aes(fill = domestic_activity), alpha = 0.7) +
  
  geom_vline(aes(xintercept = 2020.5), linetype = "dashed") +
  
  labs(x = "ECA country",
    y = "2013-2023 commitment\n(All instruments, USD2020 billion)", fill = "Recipient country in...") +
  
  facet_wrap(~ff_re_other, scales = "free") +

  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05,
                                    face = "bold", size = fontsize_general),
        strip.background = element_rect(fill = "#b8d3be",
                                        color = NA),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        strip.text = element_text(size = fontsize_general, margin = margin(2, 0, 2, 0, "pt")),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  coord_flip() +
  
  guides(fill = guide_legend(nrow = 1, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# summary stats for Denmark
df_countryfigure_final %>% filter(ff_re_other == "Renewables", ecacountry_grouped == "Denmark") %>%
  mutate(share = y_var/sum(y_var))

# horizontal version: commitments by income group of recipient country
highincome_panel <- df %>%
  
  # impute high-income country status for JERSEY (JEY) as group is NA in WB raw data
  mutate(wbcountryclassification_clean = case_when(dealcountry == "Jersey" ~ "High income",
                                                   TRUE ~ wbcountryclassification_udpated )) %>%
  
  # convert wbcountryclassification_clean into a factor variable
  mutate(wbcountryclassification_clean = factor(wbcountryclassification_clean,
                                                levels = c("Low income",
                                                           "Lower middle income",
                                                           "Upper middle income",
                                                           "High income"))) %>%
  
  # add the phases as a factor variable
  mutate(closingyear_phase = factor(case_when(closingyear %in% 2013:2015 ~ "P1",
                                       closingyear %in% 2016:2019 ~ "P2",
                                       closingyear %in% 2020:2021 ~ "P3",
                                       closingyear %in% 2022:2023 ~ "P4",
                                       TRUE ~ "INSPECT XXX"))
         ) %>%
  
  # collapse ECA commitments by recipient country income group and phase
  group_by(wbcountryclassification_clean, closingyear_phase) %>%
  summarize(ecainvolvementonthedealin = sum(ecainvolvementonthedealin)) %>% ungroup() %>%
  
  # calculate the share of commitments by phase and income group
  group_by(closingyear_phase) %>% mutate(share = ecainvolvementonthedealin/sum(ecainvolvementonthedealin)) %>% ungroup() %>%
  
  # make a stacked bar chart with the phase on the x-axis and the share of commitments on the y-axis
  ggplot(aes(closingyear_phase, share)) +
  geom_col(aes(fill = wbcountryclassification_clean)) +
  
  # add (rounded) value labels for the share of commitments
  geom_label(aes(fill = wbcountryclassification_clean, label = ifelse(100*round(share, 2) > 0, paste0(100*round(share, 2), "%"), NA_character_)),
             position = position_stack(vjust = 0.5, reverse = F),
             size = 6/.pt,
             label.padding = unit(0.1, "lines"),
             show.legend = F) +
  
  # add dashed vertical lines to separate the phases
  geom_vline(xintercept = c(2015.5, 2019.5, 2021.5), linetype = "dashed", colour = "darkred", linewidth = 0.5) +
  
  # set the y-axis to percentage scale
  scale_y_continuous(labels = scales::percent) +
  
  # set the fill colors manually
  scale_fill_manual(values = palette_ipcc_temp_4col) +
  
  # add labels to the x-axis and y-axis and the fill legend
  labs(fill = "Recipient country group", y = "Share in ECA commitments\n(all instruments)",
       x = NULL) +
  
  # set the theme elements manually
  theme(legend.position = "bottom",
        axis.title.y = element_text(#angle = 0, vjust = 1.05, hjust = 1, 
                                    face = "bold",
                                    size = fontsize_general),
        axis.title.x = element_text(size = fontsize_general),
        axis.text = element_text(size = fontsize_general),
        legend.title = element_text(size = fontsize_general),
        legend.text = element_text(size = fontsize_general),
        axis.line = element_line(linewidth = 0.25),
        axis.ticks = element_line(linewidth = 0.25),
        legend.key.size = unit(10,"pt"),
        legend.margin= margin(0, 0, 0, 0, "pt")) +
  
  # set the style of the fill legend manually
  guides(fill = guide_legend(nrow = 2, byrow = TRUE,
                             title.position="top", title.hjust = 0.5))

# combine the horizontal versions into lower panel using patchwork package
panel2 <- ff_panel + re_panel + highincome_panel +
            plot_layout(nrow = 1, widths = c(1, 1, 1.2), tag_level = "new") +
            plot_annotation(tag_levels = list(c("b", "", "c")))

# combine map and lower panel
ggarrange(panel1, panel2, nrow = 2, ncol = 1, align = "hv",
          heights = c(1, 1))

# save out as vector graph (300dpi, 18cm width)
ggsave(file.path("graphs",
                 paste0(Sys.Date(), " figure_geographic_implications.pdf")),
       width = 18.5, height = 14, dpi = 300, units = "cm")
