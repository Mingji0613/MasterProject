# Load required packages
library(ggplot2)

# Create a data frame from the provided data
data <- data.frame(
  Phylum = c("Firmicutes", "Bacteroidetes", "Proteobacteria", "Verrucomicrobia", "Actinobacteria", "Candidatus Melainabacteria", "Bacteria unclassified", "Synergistetes", "Lentisphaerae"),
  Abundance = c(502, 523, 530, 404, 522, 111, 147, 144, 178)
)

# Define custom color palette with lower saturation
custom_palette <- c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", "#ffd92f", "#e5c494", "#b3b3b3", "#1f78b4")

# Calculate the percentage relative to Lentisphaerae abundance
lentisphaerae_abundance <- data$Abundance[9]
data$PercentageRelative <- (data$Abundance / lentisphaerae_abundance) * 100

# Create the updated bar plot with percentage relative and adjusted axis labels
p <- ggplot(data, aes(x = reorder(Phylum, Abundance), y = Abundance, fill = Phylum)) +
  geom_bar(stat = "identity", width = 0.5) +
  scale_fill_manual(values = custom_palette) +
  coord_flip() +
  labs(
    x = "",
    y = "Count",
    title = "Phylum-level Abundance of TYR Gene-containing Microbial Taxa",
    subtitle = "Relative abundances of microbial phyla containing the TYR gene in 530 samples"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.title = element_blank(),
    legend.text = element_text(size = 8),
    plot.title = element_text(size = 12, hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    axis.title = element_text(size = 15),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10, hjust = 0),
    plot.margin = margin(0, 0, 0, 0, "cm")
  ) +
  geom_text(aes(label = Abundance), hjust = -0.1, size = 4) +
  geom_text(aes(label = paste0(round(PercentageRelative, 2), "%")), hjust = 1.1, color = "black", vjust = 0.5, size = 4)

# Add space for the legend on the right
p <- p + theme(legend.spacing = unit(1.5, "cm"))

# Save the plot as a PDF file
ggsave("phylum_abundance_plot.pdf", p, width = 12, height = 6)
