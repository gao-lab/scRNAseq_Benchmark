#! /usr/bin/env Rscript
# by caozj
# Feb 25, 2020
# 8:21:12 PM

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(viridis)
})


message("Preparing...")
path <- "output/figures"
if (! dir.exists(path)) dir.create(path, recursive = TRUE)

experiment_name_mapping <- read.csv(
  "experiment_name_mapping.csv", stringsAsFactors = FALSE
) %>% mutate(
  Train.Test = paste(Train, Test, sep = " - ")
) %>% mutate(
  Group = factor(Group, levels = Group[!duplicated(Group)]),
  Train = factor(Train, levels = Train[!duplicated(Train)]),
  Test = factor(Test, levels = Test[!duplicated(Test)]),
  Train.Test = factor(Train.Test, levels = Train.Test[!duplicated(Train.Test)])
)  # Order in the mapping table would be used to determine order in plots
method_name_mapping <- read.csv("method_name_mapping.csv", stringsAsFactors = FALSE)
df <- read.csv("output/result_summary_all.csv", stringsAsFactors = FALSE) %>%
  merge(experiment_name_mapping, all.x = TRUE) %>%
  merge(method_name_mapping, all.x = TRUE) %>%
  mutate(PercUnl = PercUnl * 100, Tool = Display.Name)

geom_tile <- function(...) ggplot2::geom_tile(..., col = "white", size = 0.3)
facet_grid <- function(...) ggplot2::facet_grid(..., scales = "free_x", space = "free_x")
scale_x_discrete <- function(...) ggplot2::scale_x_discrete(..., expand = c(0, 0))
scale_y_discrete <- function(...) ggplot2::scale_y_discrete(..., expand = c(0, 0))
stylize_heatmap <- function(gp) {
  gp + scale_y_discrete(
    name = NULL
  ) + scale_color_manual(
    limits = c(FALSE, TRUE), values = c("black", "white")
  ) + theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom",
  ) + guides(
    fill = guide_colorbar(title.position = "top", title.hjust = 0.5, barwidth = 15),
    color = FALSE
  )
}


message("Plotting Intra-dataset...")
intra_df <- df %>% filter(Data_type == "Intra-dataset", feature == "0")
gp <- ggplot(intra_df, aes(
  x = Train, y = Tool, fill = MedF1, label = round(MedF1, 2), col = MedF1 < 0.5
)) + geom_tile() + geom_text() + facet_grid(~ Group) + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(name = NULL)
ggsave(file.path(path, "scbench_Intra_MedF1.pdf"), stylize_heatmap(gp), height = 2.8, width = 10)

gp <- ggplot(intra_df, aes(
  x = Train, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + facet_grid(~ Group) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(name = NULL)
ggsave(file.path(path, "scbench_Intra_PercUnl.pdf"), stylize_heatmap(gp), height = 2.8, width = 10)


message("Plotting Inter-dataset PbmcBench...")
inter_pbmcbench_df <- df %>% filter(Data_type == "Inter-dataset", Group == "PbmcBench", feature == "0")
gp <- ggplot(inter_pbmcbench_df, aes(
  x = Train.Test, y = Tool, fill = MedF1
)) + geom_tile() + facet_grid(~ Train) + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(
  name = "Test set", breaks = inter_pbmcbench_df$Train.Test, labels = inter_pbmcbench_df$Test
) + ggtitle("Training set")
ggsave(file.path(path, "scbench_Inter_PbmcBench_MedF1.pdf"), stylize_heatmap(gp), height = 2.6, width = 11)

gp <- ggplot(inter_pbmcbench_df, aes(
  x = Train.Test, y = Tool, fill = PercUnl
)) + geom_tile() + facet_grid(~ Train) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(
  name = "Test set", breaks = inter_pbmcbench_df$Train.Test, labels = inter_pbmcbench_df$Test
) + ggtitle("Training set")
ggsave(file.path(path, "scbench_Inter_PbmcBench_PercUnl.pdf"), stylize_heatmap(gp), height = 2.6, width = 11)


message("Plotting Inter-dataset CellBench...")
inter_cellbench_df <- df %>% filter(Data_type == "Inter-dataset", Group == "CellBench", feature == "0")
gp <- ggplot(inter_cellbench_df, aes(
  x = Test, y = Tool, fill = MedF1, label = round(MedF1, 2), col = MedF1 < 0.5
)) + geom_tile() + geom_text() + facet_grid(~ Train) + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(name = "Test set") + ggtitle("Training set")
ggsave(file.path(path, "scbench_Inter_CellBench_MedF1.pdf"), stylize_heatmap(gp), height = 3, width = 5)

gp <- ggplot(inter_cellbench_df, aes(
  x = Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + facet_grid(~ Train) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(name = "Test set") + ggtitle("Training set")
ggsave(file.path(path, "scbench_Inter_CellBench_PercUnl.pdf"), stylize_heatmap(gp), height = 3, width = 5)


message("Plotting Inter-dataset Brain...")
inter_brain_df <- df %>% filter(Data_type == "Inter-dataset", Group == "Brain", feature == "0")
gp <- ggplot(inter_brain_df, aes(
  x = Train.Test, y = Tool, fill = MedF1, label = round(MedF1, 2), col = MedF1 < 0.5
)) + geom_tile() + geom_text() + facet_grid(~ Test) + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(
  name = "Training set", breaks = inter_brain_df$Train.Test, labels = inter_brain_df$Train
) + ggtitle("Test set")
ggsave(file.path(path, "scbench_Inter_Brain_MedF1.pdf"), stylize_heatmap(gp), height = 3.2, width = 7)

gp <- ggplot(inter_brain_df, aes(
  x = Train.Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + facet_grid(~ Test) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(
  name = "Training set", breaks = inter_brain_df$Train.Test, labels = inter_brain_df$Train
) + ggtitle("Test set")
ggsave(file.path(path, "scbench_Inter_Brain_PercUnl.pdf"), stylize_heatmap(gp), height = 3.2, width = 7)


message("Plotting Inter-dataset Brain (deep)...")
inter_brain_deep_df <- df %>% filter(Data_type == "Inter-dataset", Group == "Brain (deep)", feature == "0")
gp <- ggplot(inter_brain_deep_df, aes(
  x = Train.Test, y = Tool, fill = MedF1, label = round(MedF1, 2), col = MedF1 < 0.5
)) + geom_tile() + geom_text() + facet_grid(~ Test) + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(
  name = "Training set", breaks = inter_brain_deep_df$Train.Test, labels = inter_brain_deep_df$Train
) + ggtitle("Test set")
ggsave(file.path(path, "scbench_Inter_Brain_deep_MedF1.pdf"), stylize_heatmap(gp), height = 3.2, width = 7)

gp <- ggplot(inter_brain_deep_df, aes(
  x = Train.Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + facet_grid(~ Test) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(
  name = "Training set", breaks = inter_brain_deep_df$Train.Test, labels = inter_brain_deep_df$Train
) + ggtitle("Test set")
ggsave(file.path(path, "scbench_Inter_Brain_deep_PercUnl.pdf"), stylize_heatmap(gp), height = 3.2, width = 7)


message("Plotting Inter-dataset Pancreas...")
inter_pancreas_df <- df %>% filter(Data_type == "Inter-dataset", Group == "Pancreas", feature == "0")
gp <- ggplot(inter_pancreas_df, aes(
  x = Test, y = Tool, fill = MedF1, label = round(MedF1, 2), col = MedF1 < 0.5
)) + geom_tile() + geom_text() + scale_fill_viridis(
  name = "Median F1-score", limits = c(0, 1)
) + scale_x_discrete(name = "Test set")
ggsave(file.path(path, "scbench_Inter_Pancreas_MedF1.pdf"), stylize_heatmap(gp), height = 2.8, width = 5)

gp <- ggplot(inter_pancreas_df, aes(
  x = Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(name = "Test set")
ggsave(file.path(path, "scbench_Inter_Pancreas_PercUnl.pdf"), stylize_heatmap(gp), height = 2.8, width = 5)


message("Plotting Rejection Negative control...")
rejection_nc_df <- df %>% filter(Data_type == "Rejection", Group %in% c("Human", "Mouse"), feature == "0")
gp <- ggplot(rejection_nc_df, aes(
  x = Train.Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + facet_grid(~ Group) + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(name = "Training set - Test set")
ggsave(file.path(path, "scbench_Rejection_Negative_control_PercUnl.pdf"), stylize_heatmap(gp), height = 3.7, width = 5)


message("Plotting Rejection Unseen population...")
rejection_unseen_df <- df %>% filter(Data_type == "Rejection", Group == "Unseen population", feature == "0")
gp <- ggplot(rejection_unseen_df, aes(
  x = Test, y = Tool, fill = PercUnl, label = round(PercUnl, 1), col = PercUnl < 50
)) + geom_tile() + geom_text() + scale_fill_viridis(
  name = "Unlabeled (%)", limits = c(0, 100)
) + scale_x_discrete(name = "Cell population")
ggsave(file.path(path, "scbench_Rejection_Unseen_population_PercUnl.pdf"), stylize_heatmap(gp), height = 3.8, width = 5)


message("Done!")
