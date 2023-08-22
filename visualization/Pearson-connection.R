library(ggm)
library(psych)

otu = read.csv('Genus.csv',row.names = 1)
meta = read.csv('TYR.csv',row.names = 1)
otu = t(otu)
otu = as.data.frame(otu[rownames(meta),])


name = NA
#associations to diet and microbiome was done by Spearman correlation
microbiome = otu
metabolites = meta
pvals = matrix(NA,ncol = ncol(microbiome),nrow = ncol(metabolites))
cors = matrix(NA,ncol = ncol(microbiome),nrow = ncol(metabolites))
for(i in 1:ncol(microbiome)){
  for(j in 1:ncol(metabolites)){
    a=microbiome[is.na(microbiome[,i])==F&is.na(metabolites[,j])==F,i]
    b=metabolites[is.na(microbiome[,i])==F&is.na(metabolites[,j])==F,j]
    if(length(a)>2&length(b)>2){
      cor = cor.test(a,b,method = "spearman")
      pvals[j,i] = cor$p.value
      cors[j,i] = cor$estimate
    }
  }
}
qvals = matrix(p.adjust(pvals,method = "BH"),ncol = ncol(pvals))
colnames(qvals) = colnames(microbiome)
rownames(qvals) = colnames(metabolites)
colnames(cors) = colnames(microbiome)
rownames(cors) = colnames(metabolites)
ind = which(pvals <=1,arr.ind = T)
association = data.frame(metabolites = colnames(metabolites)[ind[,1]],microbiome = colnames(microbiome)[ind[,2]],Cor = cors[ind],Pval = pvals[ind],Qval = qvals[ind],stringsAsFactors = F)
association$name=paste(association$metabolites,association$microbiome,sep = "_with_")
colnames(association)[1:2]=name
qvals[is.na(qvals)]=1
cors=cors[row.names(qvals),colnames(qvals)]
write.csv(association,file = 'pearson.csv')


#####??ͼ??????????pֵrֵ?????????棩######
library(ggplot2)
#??????ͼ
a<-otu[,c("Coprococcus.sp...r_02379.")]
b<-meta[,c("probiot")]
data1129<-cbind(a,b)
data1129<-as.data.frame(data1129)
colnames(data1129)<-c("Coprococcus.sp...r_02379.","probiot")
p <- ggplot(data1129,aes(x=Coprococcus.sp...r_02379.,y=probiot)) + labs(x="Coprococcus" ,y="probiotic")
#???ӵ??ߣ???????ɫ????Ϊ��ɫ??0073C2FF"??Ϊ??ɫ"#FC4E07"??????ɫ????https://www.cnblogs.com/biostat-yu/p/13839621.html
p<-p+ geom_point(size = 3,color = "#0073C2FF")+geom_smooth(aes(color = "#FC4E07", fill = "#FC4E07"),size=3,method=lm)
#?????????ᣬsizeΪ??С
p<-p+theme_classic()+theme(axis.line = element_line(colour = "black",size = 1.2))+theme(axis.text=element_text(size=18),
                                                                                        axis.title=element_text(size=24,face="bold"))+ guides(fill="none",color="none")
#????r??p??ֵ
p<-p+annotate("text",x=8,y=22,size=5,label="italic(r)=='0.076,'~italic(p)=='0.029'",parse=TRUE)
#????
ggsave(p, filename = "pic.pdf",
       scale = 1, width = 12, height = 9,dpi = 300)
ggsave(p, filename = "pic.tiff",
       scale = 1, width = 12, height = 9,dpi = 300)

