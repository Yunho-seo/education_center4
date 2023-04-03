library(proxy)
install.packages("kernlab")
library(kernlab)
(x <- matrix(1:16, nrow=4))  # 4x4
sqrt(sum((x[1, ] - x[4, ])^2))  # 요소끼리 연산.
sqrt(sum((x[, 1] - x[, 4])^2))

# distance
(dist <- dist(x, method="euclidean"))  # 거리값 측정 => 두개의 벡터 간 문제. 
# (1:3 열, 2:4 행 : 3x3으로 나오는 이유? = 자신은 빼고 두개의 거리값을 측정하기 때문이다.) (n-1, n-1 행렬)
(dist <- dist(x, method = "minkowski", p=2))  # minkowski 거리 / 차의 n승을 사용하면 euclidean의 거리가 된다.
(dist <- dist(x, method = "binary"))  # 2진수로 데이터를 표현한 다음, 다른 비트의 수 ~ 거리
(dist <- dist(x, method = "manhattan"))  # manhattan 거리 / x축과 y축 = 직선값대로 계산 (거리값이 여러 개이다)
# (dist <- dist(x, method = "mahalanobis"))  # mahalanobis 거리 / 평균과의 거리가 표준편차의 몇 배인가?

# 거리 행렬도 정방행렬이면서 대칭행렬이다.

# 탐색적 군집분석(계층적 군집분석), 확인적 군집분석
# 군집수의 개수를 결정하기 위해서 탐색적으로 실시하는 군집분석이다.
idx = sample(1:dim(iris)[1], 40)  # 40개 랜덤으로 추출
irisSample = iris[idx, ]
species <- irisSample$Species  # 백업
irisSample$Species = NULL  # 품종으로는 거리값을 구할 수 없어서 NULL로 초기화. (지도학습 -> 비지도학습)
# dist는 행렬 거리값.
hc = hclust(dist(irisSample), method = "ave")  # hierachical : 계층적 (군집분석) (dist(irisSample)) 에 대한 군집분석.
plot(hc, hang = -1, labels=iris$Species[idx])
rect.hclust(hc, k=3)
(groups = cutree(hc, k=3))
table(groups, species)  # 종(species) 별로 그룹화하여 테이블 생성하기. ( 대각선이 아닌 이유는 오분리 )


clusters <- hclust(dist(iris[, 3:4]))
plot(clusters)
clusterCut <- cutree(clusters, 3)  # CUt() : 범주화 한 것처럼 -> 군집 번호를 리턴.
table(clusterCut, iris$Species)
# 핵심 개념
# 거리값 : 두개간의 거리 => 군집 간에는 여러개의 데이터가 있는데, 무엇을 기준으로 ?
# single linkage : 두 군집의 가장 가까운 두 점 사이의 거리
# complete linkage : 두 군집의 가장 먼 두 점 사이의 거리
# Average linkage : 각 거리의 평균값
# ward : 군집 내 편차들의 제곱합을 고려하여 거리값을 측정 (비교적 정확한 거리값을 측정할 수 있음)
clusters <- hclust(dist(iris[, 3:4]), method = 'average')
plot(clusters)
library(ggplot2)
clusterCut <- cutree(clusters, 3)
clusterCut
table(clusterCut, iris$Species)
ggplot(iris, aes(Petal.Length, Petal.Width, color=iris$Species)) + 
  geom_point(alpha = 0.4, size = 3.5) + geom_point(col = clusterCut) +
  scale_color_manual(values = c('black', 'red', 'green'))

# kmeans
# kmeans -> 중심값을 고려.
# 확인적 클러스터링 (확인적 군집분석)
# 중심값과 k값이 필요하다.
# 절차 : 랜덤하게 중심값을 결정 -> k값을 결정 -> 각 중심과 데이터의 거리값을 계산 -> 거리값을 가지고 그룹을 지정 ->
# 중심값을 재계산 -> 각 중심과 거리값을 계산 -> 반복 (WSS가 작아질때까지 (군집 내 응집도 최대화 / 군집 간 분리도 최대화))

set.seed(1)  # 시드 값을 주는 이유? : random으로 결정되는 값을 일정하게 하여, 결과값을 동일하게 하기 위해.
iris_back <- iris
iris_back$Species <- NULL  # 비지도학습
# 거리를 기준으로 할 때에는, 반드시 정규화해야 한다.
iris.scaled <- scale(iris_back[, -5])  # scale을 하지 않는다면, 변수의 사이즈 크기가 거리값에 영향을 미침.
# 근거를 만들어야 함 (이미 Species 종류가 3개인 것을 알고 있어서 3을 사용했지만 원래는 잘 모른다.)
(kmeans.result <- kmeans(iris.scaled, 3, trace=T))
table(iris$Species, kmeans.result$cluster)
# 산점도에 컬러값을 지정.
# 4개의 변수 중 2개의 변수만을 고려하여 시각화
plot(iris.scaled[, c("Sepal.Length", "Sepal.Width")], xlim=c(-2, 2), ylim=c(-2, 2),
     col=kmeans.result$cluster)
# 포인트는 centers 점을 기준으로 함.
points(kmeans.result$centers[, c("Sepal.Length", "Sepal.Width")],  # Sepal.Length와 Width만 사용
       col=1:3, pch=10, cex=10)

(iris_back$Species <- iris$Species)
iris_back$Species <- as.factor(iris_back$Species)
(iris_back$pred <- kmeans.result$cluster)  # 종속 변수
# sum(iris_back$Species == iris_back$pred)
names(kmeans.result)
kmeans.result$cluster
kmeans.result$centers  # 클러스터의 중심값
kmeans.result$totss 
kmeans.result$withinss  # 그룹 내 거리의 합
kmeans.result$betweenss  # 그룹 간 거리의 합
kmeans.result$tot.withinss
sum(kmeans.result$withinss)  # 3개의 그룹
# kmeans.result$totss = kmeans.result$betweenss + kmeans.result$tot.withinss
kmeans.result$iter  # 2회전
kmeans.result$size  # 속해있는 요소(데이터)의 개수

km.res <- kmeans(iris.scaled, 3, nstart=10)
library(factoextra)
# 4가지 요소를 고려한 시각화
fviz_cluster(km.res, iris[, -5], ellipse.type = "norm")

# 클러스터 개수 구하기
library(caret)  # 자동화 패키지
set.seed(123)
# 샘플링 대신에, createDataPartition() 함수를 만들어서 데이터 분할.
inTrain <- createDataPartition(y = iris$Species, p=0.7, list=F)  # 30%
training <- iris[inTrain, ]
testing <- iris[-inTrain, ]
training.data <- scale(training[-5])  # 4개의 숫자 데이터
summary(training.data)
# 중심값을 재계산. (iter.max = 10000) 1만번.
iris.kmeans <- kmeans(training.data[, -5], centers = 3, iter.max = 10000)
training$cluster <- as.factor(iris.kmeans$cluster)  # 그룹번호
qplot(Petal.Width, Petal.Length, colour = cluster, data=training)
table(training$Species, training$cluster)
# install.packages("NbClust")
library(NbClust)
# kmeans로 그룹수를 조절 => 판단근거는 거리값의 합.
nc <- NbClust(training.data, min.nc = 2, max.nc = 15, method="kmeans")  # nc = 그룹수 
par(mfrow=c(1, 1))
barplot(table(nc$Best.n[1, ]),
        xlab="클러스터수", ylab="기준",
        main="클러스터 개수 확인")

# Within sum of squares
dim(training.data)
wssplot <- function(data, nc=15, seed=1234) {
  wss <- (nrow(data)-1) * sum(apply(data, 2, var))
  for (i in 2:nc) {  # 클러스터의 개수.
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)  # 그룹 내의 거리 합
    kmeans(data, centers=i)$withiness
  }
  plot(1:nc, wss, type="b", xlab="클러스터수", ylab="SS")
}
wssplot
wssplot(training.data)

# 문제
# 중학교 1학년 신체검사 결과 -> 군집분석으로 라벨링하기
# 군집분석 -> scaling(스케일링)
body <- read.csv("bodycheck.csv", header = T, encoding="UTF-8")
names(body)
head(body)
str(body)
unique(body$안경유무)  # 범주형 -> 숫자.
(df <- body[, -1])
df <- na.omit(df)
# 열 이름 변경
colnames(df) <- c("handpw", "height", "weight", "glass")
df <- scale(df)
class(df)
df <- as.data.frame(df)
k2 <- kmeans(df, centers = 2, nstart = 25)  # 중심점 선택 : random하게 함. => 랜덤한 셋을 25번하여 좋은 결과를 사용
library(factoextra)
fviz_cluster(k2, data=df)
df$cluster <- as.factor(k2$cluster)
plot(df$handpw, df$weight, col = df$cluster)
points(k2$centers[, c("handpw", "weight")], col=c(1, 2), pch=8, cex=5)
k2$centers

# 문제
# diamonds 데이터에 대해 price, carat, depth, table 변수 데이터만을 대상으로
# 탐색적 / 확인적 군집분석을 실시
# 전체 데이터(53940개) 중 1000개만을 샘플링하여 작업할 것 
# 조건 1) 탐색적 군집분석을 실시하고 군집 수 결정
# 조건 2) 가격에 영향을 미치는 요인에 대해 설명
# 조건 3) carat과 price의 관계를 군집으로 구분하여 시각화
?diamonds
str(diamonds)
t <- sample(1:nrow(diamonds), 1000)
length(t)  # 1차원이라서 dim(t)이 아닌 length(t)
test <- diamonds[t, ];
dim(test)  # 1000 x 10
(mydia <- test[c("price", "carat", "depth", "table")])
dim(mydia)  # 1000 x 4
# hclust()에는 거리 행렬이 입력된다.
class(dist(mydia))  # dist
dim(dist(mydia))    # 기본 데이터타입이 아니다.
# 그룹과 그룹의 거리 : single(가장 가까운 거리), complete(가장 먼 거리), average(평균값), ward(편차들의 제곱)
# 탐색적 군집분석.
result <- hclust(dist(mydia), method="average")  # hclust()의 메서드는, 그룹과 그룹의 거리를 구할 때 사용
plot(result, hang = -1)
fviz_dend(res, rect=T, cex=0.5, k_colors = c("#00AFBB", "#2E9FDF", "#E7B800", "#FC4E07"))
(res <- hcut(mydia, k=4, stand=T))

mydia <- scale(mydia)
str(mydia)
class(mydia)
mydia <- as.data.frame(mydia)
(result2 <- kmeans(mydia, 4))  # kmeans() => 군집 분석 : 행과의 거리.
result2$centers  # 중심점이 4개
result2$cluster  # 4개(변수)의 종류가 1,000개
unique(result2$cluster)
length(result2$cluster)
# totss(모든 거리의 합) = 군집 내 거리 + 군집 간 거리
result2$withinss  # 군집 내 거리
result2$tot.withinss  # 군집 내 거리의 합, WSS 값 (Within sum of square)
result2$betweenss  # 군집 간 거리

# 원본 데이터 + 라벨을 결정 => 예측 문제가 분류 문제로 바뀜
mydia$cluster <- result$cluster
head(mydia)
plot(mydia[, -5])
cor(mydia[, -5], method = "pearson")
library(corrgram)
corrgram(mydia[, -5])
plot(mydia$carat, mydia$price)
# plot(mydia$carat, mydia$price, col=mydia$cluster)
points(result2$centers[, c("carat", "price")], col=c(3, 1, 2), pch=8, cex=5)

# 청소년 성향에 대한 설문 조사를 진행한 데이터
# SNS 계정을 가진 4개의 기본정보와, 36개의 관심 분야
# 청소년 성장 코미디 :
  # 범죄 성향, 운동 성향, 외모 지향, 무기력, 브레인

teens <- read.csv("./snsdata.csv") # 30000 x 40, 종속변수가 없음 => 비지도학습
set.seed(1000)
str(teens)
head(teens)
# gender, age에 결측치 발생
# gradyear, gender, age, friends : 기본정보
sum(is.na(teens$gradyear))
sum(is.na(teens$friends))
sum(is.na(teens))  # NA가 7810개
colSums(apply(teens, 2, is.na))

table(teens$gender)
summary(teens$age)
teens$age <- ifelse(teens$age >= 13 & teens$age < 20, teens$age, NA)  # 나이가 13~19세가 아니면 NA
summary(teens$age)
mean(teens$age, na.rm=T)  # 평균이 17.25243세
?ave
# 졸업년도별로 나이의 평균
(avg <- ave(teens$age, teens$gradyear, FUN=function(x) mean(x, na.rm=T)))
(teens$age <- ifelse(is.na(teens$age), avg, teens$age))  # 삼항 연산자
teens$age[1:6]
summary(teens$age)

interests <- teens[5:40]  # 1, 2, 3, 4번은 기본정보라서 제외
summary(interests)
interests_n <- data.frame(lapply(interests, scale))
summary(interests_n)
teen_clusters <- kmeans(interests_n, 5)
teen_clusters$size
table(teen_clusters$cluster)
#
# 그룹의 명명식 => 클러스터를 대표하는 것은 중심값.
# 범죄 성향, 운동 성향, 외모 지향, 무기력, 브레인
teen_clusters$centers  # 중심값으로 그룹의 성향을 네이밍한다.

teens$cluster <- teen_clusters$cluster
aggregate(data = teens, age ~ cluster, mean)  # 클러스터 별로 나이의 평균 구하기
qplot(cluster, age, color=gender, data=teens)
res <- aggregate(data=teens, gender=='F' ~ cluster, mean)
plot(res, type='b', lty=2)
aggregate(data=teens, softball + volleyball + hair + dress ~ gender == 'F', mean)

# 문제
# 클러스터별 자기가 알고싶은 성향을 확인하여 제출
# 3개 이상
#######################
# 1. 남자는 음악과 드레스에 관심이 많은가?
aggregate(data=teens, music + dress ~ gender == 'M', mean)

# 2. 남자는 음주와 마약에 관심이 많은가?
aggregate(data = teens, drunk + drugs ~ gender=='M', mean)

# 3. 여자는 야구 + 스포츠에 관심이 많은가?
aggregate(data = teens, basketball + sports ~ gender=='F', mean)

# 4. 여자는 쇼핑에 관심이 많은가?
aggregate(data = teens, shopping ~ gender=='F', mean)
#######################

# DTW (dynamic time warping) : 동적 시간 워핑, 두개의 시계열 데이터의 유사성을 비교
# 연속형 수치를 비교 (신호) : 지연, 노이즈(noise)
# install.packages("dtwclust")
library("dtwclust")
data(uciCT)
str(CharTraj)
class(CharTraj)  # 열별로 데이터 사이즈가 다르다
# dim(CharTraj)
# 선형보간법 : 사이즈를 일치시키기 위해, 없는 부분은 보간법으로 채워서 계산한다.
series <- reinterpolate(CharTraj, new.length = max(lengths(CharTraj)))
class(series)
(series <- zscore(series))  # zscore : NaN은 0으로 채우라는 의미.
pc.dtwlb <- tsclust(series, k=20L,  # tsclust : series에 대해 클러스터, 20번 반복
                    distance = "dtw_lb", centroid = "pam",  # dtw_lb : 신호에 맞추어서 
                    seed = 3247, trace = T,  # trace = T : 출력 여부
                    control = partitional_control(pam.precompute = F),  # 미리 계산
                    args = tsclust_args(dist = list(window.size = 20L))) 
plot(pc.dtwlb)
