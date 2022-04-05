library("tidyr")
library("scales")
library("ggrepel")
library("ggplot2")
library("patchwork")
source("code/utils/getLegend.R")

scale_trans = trans_new(
  "scale_trans",
  transform = function(x) {sign(x) * sqrt(abs(x))},
  inverse = function(x) {sign(x) * x^2},
  breaks = extended_breaks(),
  minor_breaks = regular_minor_breaks(),
  format = format_format(),
  domain = c(-Inf, Inf)
)

data = data.frame(readRDS("data/sample.rds"))
mdl = readRDS("data/GMM_model.rds")
transformator = readRDS("data/transformator.rds")
data_trans = recipes::bake(transformator, data, composition = "data.frame")
legend = getLegend("code/misc/colors.qml")
if (!dir.exists("plots")) dir.create("plots")

cluster_order = c("UME", "UMI", "UMV", "UMS", "UHE",
                  "PRH", "PRMu", "PRMl", "PRLu", "PRLl",
                  "PDV", "PDEu", "PDEl", "PSI", "PSG",
                  "PSF", "PFR", "PFD", "PFSu", "PFSl")
legend = legend[match(cluster_order, legend$label), ]

# transform data to long format
data = cbind(data, cluster = mdl$classification, uncertainty = mdl$uncertainty)
data$cluster = as.factor(data$cluster)
rm(mdl)
# use sample
data_long = tidyr::pivot_longer(data[1:10000, ], cols = 1:10,
                                names_to = "variable")
data_long$variable = as.factor(data_long$variable)

#### uncertainty ####
# match factor order
data_long$cluster = factor(data_long$cluster, levels = legend$value)
ggplot(data_long, aes(x = cluster, y = uncertainty)) +
  geom_violin(aes(fill = cluster), scale = "width", show.legend = FALSE) +
  scale_fill_manual(values = legend$color) +
  scale_x_discrete(labels = legend$label) +
  ylim(0, 1) +
  xlab("Surface type") +
  ylab("Uncertainty") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"))

ggsave(filename = "plots/uncertainty.pdf", device = cairo_pdf,
       height = 3, width = 8, units = "in")

#### crosstable ####
crosstable = read.csv2("data/crosstable.csv")
colnames(crosstable)[1] = "cluster"
crosstable$cluster = factor(crosstable$cluster, levels = cluster_order)

# assign 0 if cluster contains fewer than 500 objects
rem = function(x) ifelse(x < 500, 0, x)
crosstable[, 2:7] = lapply(crosstable[, 2:7], FUN = rem)

ct_long = tidyr::pivot_longer(crosstable, cols = 2:7, names_to = "form")
ct_long$form = as.factor(ct_long$form)

# calculate sum of areas
sum_form = colSums(crosstable[, 2:7])
sum_form = sum_form / max(sum_form)

form_order = c("Coastlands", "Plains...lakelands", "Plains...denudated",
               "Highlands", "Forelands", "Mountains")
form_order = rev(form_order)
form_labels = form_order
form_labels[4:5] = c("Plains-\ndenudated", "Plains-\nlakelands")

ggplot(ct_long) +
  geom_col(aes(x = value, y = form, fill = cluster), width = sum_form,
           position = position_fill(reverse = TRUE), show.legend = FALSE) +
  scale_fill_manual(values = legend$color) +
  scale_x_continuous(expand = expansion(add = c(0, 0.01))) +
  scale_y_discrete(limits = form_order, labels = form_labels) +
  xlab("Occurrence ratio") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line.y = element_blank(),
        aspect.ratio = 1/4)

ggsave(filename = "plots/zones.pdf", device = cairo_pdf, height = 5, width = 8,
       units = "in")

#### PCA ####
data_pca = prcomp(data_trans, center = FALSE, scale. = FALSE)
df_pca = data.frame(data_pca$x)[1:100000, ]
cluster_centers = aggregate(data_trans, list(cluster = data$cluster), "mean")
# match centroids order to colors order
cluster_centers = cluster_centers[match(legend$value, cluster_centers$cluster), ]
centers_pca = predict(data_pca, cluster_centers[, -1])
centers_pca = as.data.frame(centers_pca)
varnames = colnames(data)[1:10]

pca_arrows = function(prcomp, x, y, k = 0.5) {
  scale_x = (max(prcomp$x[, x]) - min(prcomp$x[, x]) / (max(prcomp$rotation[, x]) - min(prcomp$rotation[, x])))
  scale_y = (max(prcomp$x[, y]) - min(prcomp$x[, y]) / (max(prcomp$rotation[, y]) - min(prcomp$rotation[, y])))
  mult = min(scale_x, scale_y)
  rot_x = k * mult * prcomp$rotation[, x]
  rot_y = k * mult * prcomp$rotation[, y]
  return(data.frame(rot_x, rot_y))
}

## PC1 - PC2
arrows = pca_arrows(data_pca, x = "PC1", y = "PC2", k = 0.2)
p1 = ggplot() +
  geom_segment(data = arrows, aes(x = 0, y = 0, xend = rot_x, yend = rot_y),
               arrow = arrow(length = unit(0.2, "cm")), color = "red") +
  geom_point(data = centers_pca, aes(x = PC1, y = PC2, color = as.factor(1:20)),
             size = 3, show.legend = FALSE) +
  geom_text_repel(data = arrows, aes(x = rot_x, y = rot_y, label = varnames),
                  color = "red", size = 2.2, nudge_y = -0.1, seed = 1) +
  geom_text_repel(data = centers_pca, aes(x = PC1, y = PC2, label = legend$label),
                  size = 2.6, seed = 1) +
  scale_color_manual(values = legend$color) +
  xlab("PC1 (39.7%)") +
  ylab("PC2 (15.9%)") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"),
        aspect.ratio = 1)
p1

## PC1 - PC3
arrows = pca_arrows(data_pca, x = "PC1", y = "PC3", k = 0.2)
p2 = ggplot() +
  geom_segment(data = arrows, aes(x = 0, y = 0, xend = rot_x, yend = rot_y),
               arrow = arrow(length = unit(0.2, "cm")), color = "red") +
  geom_point(data = centers_pca, aes(x = PC1, y = PC3, color = as.factor(1:20)),
             size = 3, show.legend = FALSE) +
  geom_text_repel(data = arrows, aes(x = rot_x, y = rot_y, label = varnames),
                  color = "red", size = 2.2, nudge_y = -0.1, seed = 1) +
  geom_text_repel(data = centers_pca, aes(x = PC1, y = PC3, label = legend$label),
                  size = 2.6, seed = 1) +
  scale_color_manual(values = legend$color) +
  xlab("PC1 (39.7%)") +
  ylab("PC3 (14.1%)") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"),
        aspect.ratio = 1)
p2

### variable vs variable ###
agg = aggregate(data[, 1:10], by = list(cluster = data$cluster), FUN = mean)
agg = agg[match(legend$value, agg$cluster), ]

# `aspect_diversity` is now `mean convergence`
p3 = ggplot(agg, aes(x = FLAT, y = MCON, color = as.factor(1:20))) +
  geom_point(size = 3, alpha = 0.9, show.legend = FALSE) +
  geom_text_repel(aes(label = legend$label), color = "black", size = 2.6, seed = 1) +
  scale_color_manual(values = legend$color) +
  scale_x_continuous(trans = "sqrt") +
  xlab("Flatness") +
  ylab("Mean convergence") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"),
        aspect.ratio = 1)
p3

# `position` is now `Slope position`
p4 = ggplot(agg, aes(x = RELF, y = SPOS, color = as.factor(1:20))) +
  geom_point(size = 3, alpha = 0.9, show.legend = FALSE) +
  geom_text_repel(aes(label = legend$label), color = "black", size = 2.6, seed = 1) +
  scale_color_manual(values = legend$color) +
  scale_y_continuous(trans = scale_trans, limits = c(-0.25, 0.1)) +
  scale_x_continuous(trans = "sqrt") +
  xlab("Relief") +
  ylab("Slope position") +
  theme_bw() +
  theme(panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black"),
        axis.line = element_line(colour = "black", size = 0.5),
        axis.title = element_text(face = "bold"),
        aspect.ratio = 1)
p4

p1 + p2 + p3 + p4
ggsave(filename = "plots/cluster_distribution.pdf", device = cairo_pdf,
       height = 8, width = 8, units = "in")
