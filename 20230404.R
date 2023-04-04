# 연관분석 (Association analysis)
# install.packages("arules")
library(arules)  # apriori 알고리즘을 구현한 패키지 (연관 구현성)
data("Adult")  # transaction 거래행렬 (범주형 데이터에 대해 행렬로 구성)
  # ngCMatrix : sparse matrix(희소행렬) (메모리 낭비 문제 때문에 별도로 저장 => 희소행렬이 사용되는 이유) : text mining
  # 마트에는 품목이 많음 -> 장바구니 (희소)
  # 희소행렬을 표현하는 방법 (인접행렬(공간을 낭비), 그래프 표현(메모리는 절약 -> 처리 시간은 증가))
str(Adult)
  # @ : S4 class
  # S3는 함수를 이용해서 클래스를 생성 (R은 함수(1급 객체)를 이용하는 프로그래밍)
rules <- apriori(Adult)  # 6137개의 rule이 발생
rules.sub <- subset(rules, subset = rhs %in% "marital-status=Never-married" & lift > 2)
rules.sub  # 58 rules
inspect(rules.sub)

rules.sub <- subset(rules, subset = lhs %ain% c("age=Young", "workclass=Private"))
rules.sub
inspect(rules.sub)  # 76 rules

# 중요한 룰(rule)을 생성하고자 할 때 paratemer를 이용한 제약조건 설정(support, confidence를 이용한 제약)
rules <- apriori(Adult, parameter = list(supp=0.5, conf=0.8, minlen=2))  # rule이 80개

# install.packages("arulesViz")
library(arulesViz)
plot(rules, method="graph", engine="interactive")
# in(섞어도 된다), ain(전체) , pin(partial)
white.lhs <- subset(rules, lhs %in% "race=White")
length(white.lhs)
inspect(white.lhs)
plot(white.lhs, method="graph")

# 문제
# race=White에서, native-country = United-State인 것이 lhs에 나타나는
# rule 조합을 선택.
whiteORus.lhs <- subset(rules, lhs %in% "race=White", lhs %in% "native-country=United-States")
inspect(whiteORus.lhs)  # 24

# rules에 대해 support와 confidence를 이용하여 정렬(내림차순)한 다음, 상위 3개만 출력
inspect(head(rules))
?sort  # 오버로딩
inspect(head(sort(rules, decreasing=T, by = c("support", "confidence")), 3))

adult <- as(Adult, "data.frame")
str(adult)
head(adult)

ar <- apriori(Adult, parameter = list(supp=0.1, conf=0.8))  # 6137 rule
ar2 <- apriori(Adult, parameter = list(supp=0.2, conf=0.95))  # 348 rule
ar6 <- apriori(Adult, parameter = list(supp=0.6, conf=0.80))  # 39 rule
inspect(head(ar6))
?apriori
rules <- apriori(Adult, parameter=list(support=0.3, confidence=0.50),
                 appearance = list(rhs = "relationship=Husband"), control = list(sort=-1))
inspect(rules)

# 문제
# 1) 최소 support = 0.5, 최소 confidence = 0.8을 지정하여 연관 규칙을 생성
ar <- apriori(Adult, parameter = list(supp=0.5, conf=0.8))  # 84 rule
inspect(ar)

# 2) 연관 분석 결과를 연관어 네트워크 형태로 시각화
plot(ar, method="graph", engine="interactive")

# 3) lhs가 white(백인)인 규칙인 subset으로 작성하고, 연관어를 시각화
ar.lhs <- subset(ar, subset = lhs %in% 'race=White')
inspect(head(sort(ar.lhs, decreasing=T, by="lift"), 10))
plot(ar.lhs)
plot(ar.lhs, method="graph")
################

data("Groceries")
?Groceries
str(Groceries)
summary(Groceries)  # summary(Groceries)  연관분석에서 사용
size(head(Groceries))
LIST(head(Groceries, 3))  # 연관분석에서는 list를 대문자로 표기한다.
itemFrequencyPlot(Groceries, topN = 15)
itemFrequency(Groceries[, 1:5])

a_matrix <- matrix(c(
  1,1,0,0,0,
  0,0,1,0,0,
  0,0,0,1,1,
  1,1,1,0,0,
  0,1,0,0,0
), ncol=5, byrow=T)  # 0 : 비구매 / 1 : 구매 
dimnames(a_matrix) <- list(paste("Tr", c(1:5), sep=""),
                           c("milk", "bread", "butter", "beer", "diapers"))
a_matrix
image(a_matrix)
trans2 <- as(a_matrix, "transactions")  # 희소행렬 처리 포맷으로 변환
trans2  # transactions 포맷 / ngCMatrix (sparse : 희소행렬)
rule <- apriori(trans2, parameter = list(supp=0.01, conf=0.01))  # rule 16개.
inspect(rule)

#####################################

# 조별 문제
# 수작업 (다음 조합에 대하여 지지도, 신뢰도, 향상도 구하기)
# {맥주} = 고기
# {라면, 우유} = 맥주

# {맥주} = 고기 
# 지지도 : 1/6
# 신뢰도 : 1/6 / 1/3 = 1/2
# 향상도 : 1/2 / 2/3 = 3/4

# {라면, 우유} = 맥주
# 라면 우유 지지도 : 1/2, 맥주 지지도 : 1/3
# 지지도 : 1/6
# 신뢰도 : 1/6 / 1/2 = 1/3
# 향상도 : 1/3 / 1/3 = 1

# 연관분석을 통해..
  # 적당한 지지도와 신뢰도를 결정
  # 향상도를 이용하여 결과를 해석하고 정렬한 다음 출력
# 데이터를 데이터베이스에 입력하고 로딩하여 처리하기 (연관분석 : 데이터베이스)

(data <- read.table("tran.txt", header=F, sep="\t"))
class(data)
length(data)
# 데이터의 길이가 다른 경우 (list)
datalist <- list()
for (i in 1:nrow(data)) {
  vector <- unlist(strsplit(data[i, 1], ","))
  datalist[i] <- list(vector)
}
datalist
# 범주 
(items <- unique(unlist(datalist))) # 5가지 품목(범주), "라면", "맥주", "우유", "고기", "과일"
# 6x5 행렬 matrix를 만들어야 함 (0, 1 데이터)
matrix <- matrix(0, nrow = nrow(data), ncol = length(items))
dim(matrix)
datalist[2]  # 2번째 행의 데이터 확인

for (i in 1:nrow(data)) {
  for(datai in datalist[i]) {
    matrix[i, match(datai, items)] <- 1
  }
}
df <- data.frame(matrix, row.names=NULL)
colnames(df) <- items
print(df)

library(dplyr)
library(dbplyr)
library(DBI)
conn = dbConnect(MySQL(), user='root', password='acorn1234', dbname='rtest',
                 host = '192.168.41.184')
dbListTables(conn)

# query
dbWriteTable(conn, "transaction_table", df)
for(i in 1:nrow(df)) {
  values <- paste0("(", paste(df[i, ], collapse = ", "), ")")
  query <- paste0("insert into transaction_table values ", values)
  dbExecute(conn, query)
}

res <- dbSendQuery(conn, "select * from transaction_table")
df <- dbFetch(res)
df
df_tran <- as(df, "transactions")
rule <- apriori(df_tran, parameter = list(supp=0.6, conf=0.3, minlen=2, maxlen=3))
inspect(rule)
plot(rule, methoe="graph")

#####################################

# data("AdultUCI")
data(AdultUCI)
str(AdultUCI)
rules <- apriori(AdultUCI)  # 19328개
# not logical or factor. 1, 3, 5, 11, 12, 13.  너무 많은 조합이 발생.
basket_rules <- apriori(AdultUCI, parameter = list(sup = 0.08, conf = 0.5, target="rules"))  # [40548 rule(s)] # not logical or factor.
count(unique(AdultUCI["age"]))  # 74개
min(AdultUCI["age"])  # 추가되는 데이터에도 적용이 가능해야 함.
max(AdultUCI["age"])
# c(15, 25, 45, 65, 100)
# ["age"] : 열을 선택 / [["age"]] : 요소
AdultUCI[["age"]] <- ordered(cut(AdultUCI[["age"]], c(15, 25, 45, 65, 100)),
                             labels=c("young", "middle", "senior", "old"))

AdultUCI["fnlwgt"] <- NULL  # 필요 없는 데이터는 Null값 처리
AdultUCI["education-num"] <- NULL
AdultUCI[["capital-gain"]] <- ordered(cut(AdultUCI[["capital-gain"]],
                  c(-Inf, 0, median(AdultUCI[["capital-gain"]][AdultUCI[["capital-gain"]] > 0]), Inf)),
                  labels=c("None", "Low", "High"))
AdultUCI[["capital-loss"]] <- ordered(cut(AdultUCI[["capital-loss"]],
                  c(-Inf, 0, median(AdultUCI[["capital-loss"]][AdultUCI[["capital-loss"]] > 0]), Inf)),
                  labels=c("None", "Low", "High"))
AdultUCI[["hours-per-week"]] <- ordered(cut(AdultUCI[["hours-per-week"]], c(0, 25, 40, 60, 168)),
                  labels=c("part-time", "full-time", "over-time", "workaholic"))

Adult_new <- as(AdultUCI, "transactions")
basket_rules <- apriori(Adult_new, parameter = list(sup = 0.08, conf = 0.5, target="rules"))
inspect(basket_rules[1:10])
p <- inspectDT(basket_rules)
htmlwidgets::saveWidget(p, "arules_2.html", selfcontained=F)
browseURL("arules_2.html")

# 문제
# 1) 가족관계 및 교육수준이 소득과의 연관성 확인
# {가족관계, 교육수준} = 소득
# {relationship, education} -> income
str(AdultUCI)
summary(adult)
adult <- AdultUCI
count(unique(adult["relationship"]))
count(unique(adult["education"]))

head(cbind(AdultUCI["relationship"], AdultUCI["education"]))
re1 <- apriori(cbind(AdultUCI["relationship"], AdultUCI["education"], AdultUCI["income"]), parameter = list(supp=0.01, conf=0.01))
re1 = subset(re1, rhs %pin% 'income')
inspect(re1)

# 2) 주당 일하는 시간과 소득과의 관계를 확인
str(adult)
re2 <- apriori(AdultUCI[c("hours-per-week", "income")], parameter = list(supp=0.01, conf=0.01))
re2 = subset(re2, rhs %pin% 'income')
inspect(re2)

# 3) 기타 위의 데이터로부터 자기가 주장하고자하는 내용을 확인하고 의견을 제시

# 나이와 주당 일하는 시간과의 연관성 
str(adult)
re3 <- apriori(AdultUCI[c("age", "hours-per-week")], parameter = list(supp=0.01, conf=0.01))
re3 = subset(re3, rhs %pin% 'hours-per-week')
inspect(re3)





















































