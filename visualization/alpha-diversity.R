library(reshape2)
library(vegan)
library(picante)
library(dplyr)
library(vioplot)
library(readxl)
# otu_data = read_excel("genus.xlsx")#??Ϊ????????Ϊ????
# otu_data = t(otu_data)
# Shannon <- diversity(otu_data, "shannon")
# write.csv(Shannon,file = 'Shannon.csv')
library(vioplot)

label = read.csv("Group.csv", row.names=1, header=TRUE)
# formula input
# ????ʾ??????iris
data = read.csv("Shannon.csv", row.names=1, header=TRUE)
data = as.data.frame(data[rownames(label),])
write.csv(data,file = 'Shannon.csv')
x1=data$Shannon[data$Group=="Fecal"]
x2=data$Shannon[data$Group=="Glacier lake"]
x3=data$Shannon[data$Group=="Groundwater"]
x4=data$Shannon[data$Group=="Large River"]
x5=data$Shannon[data$Group=="Sewage"]
x6=data$Shannon[data$Group=="Urban River"]

# setwd('../vsualization')
# pdf("alpha.pdf", width = 10, height = 6)
# vioplot(x1,x5,x6,x4,x2,x3, names=c("Fecal","Sewage","Urban River","Large River","Glacier lake","Groundwater"),
#         main = "Shannon diversity", # ???ñ??? 
#         col=c("#FBB4AE", "#B3CDE3","#CCEBC5", "#FFFF00", "pink", "#00FF00"),las=1)
#dev.off()  # Close the PDF device

# 打开PDF绘图设备
pdf("alpha.pdf", width = 10, height = 6)

# 绘制vioplot图
vioplot(x1, x5, x6, x4, x2, x3, 
        names = c("Fecal", "Sewage", "Urban River", "Large River", "Glacier lake", "Groundwater"),
        main = "Shannon diversity",
        col = c("#FBB4AE", "#B3CDE3", "#CCEBC5", "#FFFF00", "pink", "#00FF00"),
        las = 1)

# 添加颜色图例
legend("topright", legend = c("Fecal", "Sewage", "Urban River", "Large River", "Glacier lake", "Groundwater"),
       col = c("#FBB4AE", "#B3CDE3", "#CCEBC5", "#FFFF00", "pink", "#00FF00"), pch = 15, bty = "n")

# 关闭PDF绘图设备，保存图像到文件
dev.off()

# 打开PDF绘图设备
pdf("alpha.pdf", width = 15, height = 5.7)

# 绘制vioplot图
vioplot(x1, x5, x6, x4, x2, x3, 
        names = c("Fecal", "Sewage", "Urban River", "Large River", "Glacier lake", "Groundwater"),
        main = "Shannon diversity",
        col = c("#FBB4AE", "#B3CDE3", "#CCEBC5", "#FFFF00", "pink", "#00FF00"),
        las = 1,
        cex.axis = 1.5,  # 扩大坐标轴数字和名称字体大小
        cex.lab = 1.25,
        cex.main = 2)   # 扩大坐标轴标题字体大小

# 添加颜色图例，并设置图例字体大小
legend("topright", legend = c("Fecal", "Sewage", "Urban River", "Large River", "Glacier lake", "Groundwater"),
       col = c("#FBB4AE", "#B3CDE3", "#CCEBC5", "#FFFF00", "pink", "#00FF00"), pch = 15, bty = "n",
       cex = 1.7)  # 扩大图例字体大小

# 关闭PDF绘图设备，保存图像到文件
dev.off()






