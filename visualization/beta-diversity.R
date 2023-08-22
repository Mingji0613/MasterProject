#??????ͼ??
library(vegan)
library(ggplot2)
#??ɫѡ??
color=c( "#3C5488B2","#00A087B2", 
         "#F39B7FB2","#91D1C2B2", 
         "#8491B4B2", "#DC0000B2", 
         "#7E6148B2","yellow", 
         "darkolivegreen1", "lightskyblue", 
         "darkgreen", "deeppink", "khaki2", 
         "firebrick", "brown1", "darkorange1", 
         "cyan1", "royalblue4", "darksalmon", 
         "darkgoldenrod1", "darkseagreen", "darkorchid")

#??ȡotu?????ļ?,???????????֣???????????OTU?ķ???????
otu1 = read.csv('Genus.csv',row.names = 1)
# ????????Bray-Curtis??????Beta??????
community_matrix = as.data.frame(t(otu1))
community_matrix <- community_matrix[rowSums(community_matrix) > 0, ]

#???????????ɼ??????????룬?????? dist ???????ʹ洢
bray_dis <- vegdist(community_matrix, method = 'bray')   

#????????????
pcoa <- cmdscale(bray_dis, k = (nrow(otu1) - 1), eig = TRUE)
site <- data.frame(pcoa$point)[1:2]
site$name <- rownames(site)

#??ȡ?????ļ?,??һ?????????? ???ڶ???Group
Group = read.csv('Group.csv',row.names = 1)
Group = as.data.frame(Group[rownames(community_matrix),])
rownames(Group) = rownames(community_matrix)
colnames(Group) = "Group"
map<-Group
permanova_result <- adonis2(bray_dis ~ map$Group)
# ??ȡPERMANOVA??pֵ
p_value <- permanova_result[1,5]

#site$group <- c(rep('A', 12), rep('B', 12), rep('C', 12))
#???????ļ????????ļ????????ϲ?
merged=merge(site,map,by="row.names",all.x=TRUE)
permanova_result <- adonis2(bray_dis ~ map$Group)
#ʹ?? wascores() ???????????ֵ÷֣????꣩?????ȼ?Ȩƽ??????
otu = community_matrix
species <- wascores(pcoa$points[,1:4], otu)

#????????̫???ˣ?????Ҫ??չʾ???? top10 ????????
#???? top10 ????????
abundance <- apply(otu, 2, sum)
abundance_top10 <- names(abundance[order(abundance, decreasing = TRUE)][1:10])

species_top10 <- data.frame(species[abundance_top10,1:2])
species_top10$name <- rownames(species_top10)

pcoa_exp <- pcoa$eig/sum(pcoa$eig)
pcoa1 <- paste('PCoA axis1 :', round(100*pcoa_exp[1], 2), '%')
pcoa2 <- paste('PCoA axis2 :', round(100*pcoa_exp[2], 2), '%')

#ggplot2 ??ͼ
library(ggplot2)

# p <- ggplot(data = merged, aes(X1, X2)) +
#   geom_point(aes(color = Group)) +
#   stat_ellipse(aes(fill = Group), geom = 'polygon', level = 0.95, alpha = 0.1, show.legend = FALSE) +
#   scale_color_manual(values = color[1:length(unique(map$Group))]) +
#   scale_fill_manual(values = color[1:length(unique(map$Group))]) +
#   theme(panel.grid.major = element_line(color = 'gray', size = 0.2), panel.background = element_rect(color = 'black', fill = 'transparent'), 
#         plot.title = element_text(hjust = 0.5)) +
#   geom_vline(xintercept = 0, color = 'gray', size = 0.5) +
#   geom_hline(yintercept = 0, color = 'gray', size = 0.5) +
#   labs(x = pcoa1, y = pcoa2, title = 'PCoA') +
#   # ??p_value??ǩ?????????Ͻ?
#   geom_text(x = Inf, y = Inf, label = paste("p =", signif(p_value, digits = 3)), hjust = 1, vjust = 1, size = 4)


# p <- ggplot(data = merged, aes(X1, X2)) +
#   geom_point(aes(color = Group)) +
#   stat_ellipse(aes(fill = Group), geom = 'polygon', level = 0.95, alpha = 0.1, show.legend = FALSE) +
#   scale_color_manual(values = color[1:length(unique(map$Group))]) +
#   scale_fill_manual(values = color[1:length(unique(map$Group))]) +
#   theme(panel.grid.major = element_line(color = 'gray', size = 0.2), 
#         panel.background = element_rect(color = 'black', fill = 'transparent'), 
#         plot.title = element_text(hjust = 0.5),
#         legend.text = element_text(size = 24),   # 调整图例文本大小为12
#         legend.title = element_text(size = 24))+  # 调整图例标题大小为14
#   geom_vline(xintercept = 0, color = 'gray', size = 0.5) +
#   geom_hline(yintercept = 0, color = 'gray', size = 0.5) +
#   labs(x = pcoa1, y = pcoa2, title = 'PCoA') +
#   # ??p_value??ǩ?????????Ͻ?
#   geom_text(x = Inf, y = Inf, label = paste("p =", signif(p_value, digits = 3)), hjust = 1, vjust = 1, size = 4)


p <- ggplot(data = merged, aes(X1, X2)) +
  geom_point(aes(color = Group)) +
  stat_ellipse(aes(fill = Group), geom = 'polygon', level = 0.95, alpha = 0.1, show.legend = FALSE) +
  scale_color_manual(values = color[1:length(unique(map$Group))]) +
  scale_fill_manual(values = color[1:length(unique(map$Group))]) +
  theme(panel.grid.major = element_line(color = 'gray', size = 0.2), 
        panel.background = element_rect(color = 'black', fill = 'transparent'), 
        plot.title = element_text(hjust = 0.5),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20)) +
  geom_vline(xintercept = 0, color = 'gray', size = 0.5) +
  geom_hline(yintercept = 0, color = 'gray', size = 0.5) +
  labs(x = pcoa1, y = pcoa2, title = 'PCoA Beta Diversity Plot') +
  geom_text(x = Inf, y = Inf, label = paste("p =", signif(p_value, digits = 3)), hjust = 1, vjust = 1, size = 6)  # 调整p值标签字体大小为原来的2.5倍

p <- p + theme(axis.title.x = element_text(size = 24), axis.title.y = element_text(size = 24),
          axis.text.x = element_text(size = 24), axis.text.y = element_text(size = 24),
          plot.title = element_text(size = 24))

ggsave(p, dpi = 400, limitsize = FALSE, filename = paste0("beta", ".pdf"), width = 10, height = 8)














