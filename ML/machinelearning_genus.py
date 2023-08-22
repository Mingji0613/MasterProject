import os
import numpy as np
import pandas as pd
# 导入库
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings("ignore")
import matplotlib as mpl
# 将sans-serif字体设置为空列表，表示使用系统默认字体
mpl.rcParams['font.sans-serif'] = 'Arial'
# 设置unicode_minus为False，避免负号显示错误
mpl.rcParams["axes.unicode_minus"] = False
# 创建文件夹，方便写入图片数据
root_path = 'genus_pic'
if os.path.exists(root_path) != True: # path是文件夹或者文件的相对路径或者绝对路径
        os.mkdir(root_path)
#input data
Genus = pd.read_excel("machinelearning.xlsx",sheet_name='genus', index_col=0)
TYR = pd.read_excel("machinelearning.xlsx",sheet_name='TYR')

#data prepare
Genus = pd.DataFrame(Genus.values.T,columns=Genus.index,index=Genus.columns)
Genus['Sample ID'] = Genus.index
data =pd.merge(Genus,TYR)
data = data.drop(['Sample ID'], axis = 1)

# 数据描述
print(data.info())

#check missing values
data.isnull().sum()
col = data.columns.tolist()

####################################
# By adding a parameter kind='reg', seaborn can add a best-fit straight line and 95% confidence bands.
for i in range(len(col) - 1):
    g = sns.pairplot(data, x_vars=col[i], y_vars=col[-1], height=7, aspect=1.0, kind='reg')

    # 添加斜率信息
    ax = g.axes[0, 0]
    slope, intercept = np.polyfit(data[col[i]], data[col[-1]], 1)
    ax.text(0.95, 0.95, f'slope={slope:.2f}', transform=ax.transAxes, fontsize=12 * 2, ha='right', va='top')

    # 设置坐标标签和边距，并调整字体大小
    ax.set_ylabel('TYR (ppm)', fontsize=12 * 2)
    ax.set_xlabel(col[i], fontsize=12 * 2)
    ax.tick_params(axis='both', labelsize=12 * 2)
    g.fig.subplots_adjust(left=0.15)

    # 调整点的透明度
    for ax in g.axes.flat:
        x_values = ax.collections[0].get_offsets()[:, 0]
        y_values = ax.collections[0].get_offsets()[:, 1]
        mask = (x_values < 0.02)
        alpha_values = np.ones_like(x_values)
        alpha_values[mask] = 0.2
        ax.collections[0].set_alpha(alpha_values)

    # 调整置信区间颜色和图例
    for ax in g.axes.flat:
        for line in ax.lines:
            if "regression" in line.get_label():
                line.set_color('blue')
                line.set_linewidth(2.8)  # 增加回归线的粗细
            else:
                line.set_color('green')
                line.set_alpha(0.5)
        ax.legend(labels=['Abundance', '95% CI'], loc='upper left', fontsize=12 * 2)

    # 添加水平和垂直坐标轴网格线（方格线）
    for ax in g.axes.flat:
        ax.grid(True, linestyle='--', linewidth=0.5, color='lightgrey')

    # 调整整张图宽度并添加图例到右侧独立显示
    g.fig.set_size_inches(g.fig.get_figwidth() + 2, g.fig.get_figheight())

    plt.savefig(root_path + f"/pairplot_{col[i]}.jpg", bbox_inches='tight')
    plt.close()























# 相关系数矩阵 r(相关系数) = x和y的协方差/(x的标准差*y的标准差) == cov（x,y）/σx*σy
# 相关系数0~0.3弱相关0.3~0.6中等程度相关0.6~1强相关
m = data.corr()
m.to_csv(root_path + '/m.csv')
# 筛选正相关特征
m_result = m['tyr(PPM)'].sort_values()
m_result.to_csv(root_path + '/m_result.csv')
m_index = m_result.index.tolist()
m_values = m_result.tolist()
m_set = {}
for i in range(len(m_index)-1):
    m_set[m_index[i]] = m_values[i]
m_set
# 分别获取强相关，中等相关，弱相关列名
s_1, s_2, s_3 = [], [], []
for key,value in m_set.items():
    if 0 < value < 0.1:
        s_1.append(key)
    elif 0.1 < value <= 0.2:
        s_2.append(key)
    elif 0.2 < value <= 1:
        s_3.append(key)
    else:
        print(key,value)


##################### MODEL ######################
#导入数据集拆分工具
from sklearn.model_selection import train_test_split
# 数据集划分
y = data['tyr(PPM)'].astype(int)  # 以abundence为标签
X = data.drop(['tyr(PPM)'], axis = 1)

from sklearn.preprocessing import StandardScaler

#将数据拆分为训练集和验证集
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size = 0.2)
#特征预处理
sc = StandardScaler()
#标准化
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)

# 定义模型（多元线性回归）
from sklearn import linear_model
# 创建多元线性回归模型
model = linear_model.LinearRegression()

# 训练模型
model.fit(X_train, y_train)
a = model.intercept_  # 截距
b = model.coef_  # 回归系数

print("bestfit:intercept=", a, ",cor=", b)
print('constant:'+str(a))
score = model.score(X_test, y_test)
print('modelscore：'+str(score))

Y_pred = model.predict(X_test)
Y_pred

######################## Figure ########################
# 预测图
plt.figure(figsize = (12,7))
x = [i for i in range(len(y_test.tolist()))]
plt.plot(x, y_test, 'b', label="test data")
plt.plot(x, Y_pred, 'r', label="pred data")
# plt.xticks(x)
plt.legend(loc=2)
plt.title("Testdataset_predict")
plt.savefig(root_path + "/Testdataset_predict_standard.jpg")
plt.close()


# 残差图
# 计算残差
residuals = y_test - Y_pred

# 绘制残差图
plt.figure(figsize = (12,7))
plt.scatter(Y_pred, residuals)
plt.xlabel("Fitted Values")
plt.ylabel("Residuals")
plt.axhline(y=0, c='r')
plt.title("Residual")
plt.savefig(root_path + "/Residual_standard.jpg")
plt.close()

####################### All positive #####################
X = data[s_1 + s_2 + s_3]
#将数据拆分为训练集和验证集
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size = 0.2)
#特征预处理
sc = StandardScaler()
#标准化
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# 训练模型
model = linear_model.LinearRegression()
model.fit(X_train, y_train)
a = model.intercept_  # 截距
b = model.coef_  # 回归系数
print("bestfit:intercept=", a, ",cor=", b)
print('constant:'+str(a))
score = model.score(X_test, y_test)
print('modelscore：'+str(score))
Y_pred = model.predict(X_test)
print('Predict_value：', Y_pred)

# 预测图
plt.figure(figsize = (12,7))
x = [i for i in range(len(y_test.tolist()))]
plt.plot(x, y_test, 'b', label="test data")
plt.plot(x, Y_pred, 'r', label="pred data")
# plt.xticks(x)
plt.legend(loc=2)
plt.title("Testdataset_predict")
plt.savefig(root_path + "/Testdataset_predict_positive.jpg")
plt.close()

#  残差图
# 计算残差
residuals = y_test - Y_pred
# 绘制残差图
plt.figure(figsize = (12,7))
plt.scatter(Y_pred, residuals)
plt.xlabel("Fitted Values")
plt.ylabel("Residuals")
plt.axhline(y=0, c='r')
plt.title("Residual")
plt.savefig(root_path + "/Residual_positive.jpg")
plt.close()



############################ Medium connect #####################

X = data[s_2 + s_3]
#将数据拆分为训练集和验证集
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size = 0.2)
#特征预处理
sc = StandardScaler()
#标准化
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# 训练模型
model = linear_model.LinearRegression()
model.fit(X_train, y_train)
a = model.intercept_  # 截距
b = model.coef_  # 回归系数
print("bestfit:intercept=", a, ",cor=", b)
print('constant:'+str(a))
score = model.score(X_test, y_test)
print('modelscore：'+str(score))
Y_pred = model.predict(X_test)
print('Predict_value：', Y_pred)

# 预测图
plt.figure(figsize = (12,7))
x = [i for i in range(len(y_test.tolist()))]
plt.plot(x, y_test, 'b', label="test data")
plt.plot(x, Y_pred, 'r', label="pred data")
# plt.xticks(x)
plt.legend(loc=2)
plt.title("Testdataset_predict")
plt.savefig(root_path + "/Testdataset_predict_medium.jpg")
plt.close()

#  残差图
# 计算残差
residuals = y_test - Y_pred
# 绘制残差图
plt.figure(figsize = (12,7))
plt.scatter(Y_pred, residuals)
plt.xlabel("Fitted Values")
plt.ylabel("Residuals")
plt.axhline(y=0, c='r')
plt.title("Residual")
plt.savefig(root_path + "/Residual_medium.jpg")
plt.close()

######################### Strong connect ########################
X = data[s_3]
#将数据拆分为训练集和验证集
X_train,X_test,y_train,y_test = train_test_split(X,y,test_size = 0.2)
#特征预处理
sc = StandardScaler()
#标准化
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# 训练模型
model = linear_model.LinearRegression()
model.fit(X_train, y_train)
a = model.intercept_  # 截距
b = model.coef_  # 回归系数
print("bestfit:intercept=", a, ",cor=", b)
print('constant:'+str(a))
score = model.score(X_test, y_test)
print('modelscore：'+str(score))
Y_pred = model.predict(X_test)
print('Predict_value：', Y_pred)

# 预测图
plt.figure(figsize = (12,7))
x = [i for i in range(len(y_test.tolist()))]
plt.plot(x, y_test, 'b', label="test data")
plt.plot(x, Y_pred, 'r', label="pred data")
# plt.xticks(x)
plt.legend(loc=2)
plt.title("Testdataset_predict")
plt.savefig(root_path + "/Testdataset_predict_strong.jpg")
plt.close()

#  残差图
# 计算残差
residuals = y_test - Y_pred
# 绘制残差图
plt.figure(figsize = (12,7))
plt.scatter(Y_pred, residuals)
plt.xlabel("Fitted Values")
plt.ylabel("Residuals")
plt.axhline(y=0, c='r')
plt.title("Residual")
plt.savefig(root_path + "/Residual_strong.jpg")
plt.close()





