# install.packages("tseries")  # 시계열 분석 및 계산 재정학(Finance)에 대한 함수
# install.packages("forecast") # 선형이나 시계열을 위한 예측 함수
# install.packages("TTR")      # 기술적 트레이딩 룰 (Technical trading rule) (주석)

# MA (moving average) : 이동평균법 (5, 12, 20, 60, 120일)
# SMA (Simple)
# WMA (Weighted) : 가중이동평균 (1, 2, 3, 4, 5의 가중치(영향력))
# EMA (Exponentially) : 지수 이동 평균법 : 이자 ~ 복리를 계산
# 연관분석 : ngcMatrix : transaction (희소행렬) = 그래프적(graph)으로 표현

library(tseries)
library(forecast)
library(TTR)

ts(1:10, frequency = 4, start=c(1959, 2))  # 1959년 2사분위수부터 데이터 넣기 (freq = 4라서 1년을 4분기로 나눔) 
print(ts(1:10, frequency = 7, start=c(12, 2)), calendar = T)  # 12번 2사분위수부터 데이터 넣기 (freq = 7이라서 12번을 7로 나눔)

(gnp <- ts(cumsum(1 + round(rnorm(100), 2)), start=c(1954, 7), frequency = 12))  # cumsum() : 누적
class(gnp)  # "ts" : 시계열 데이터 포맷  # 추세를 가진 시계열이다.
plot(gnp)

# 
kings <- scan("kings.dat")
kings
kingstimeseries <- ts(kings)
kingstimeseries
plot(kingstimeseries)

# SMA
king_sma3 <- SMA(kingstimeseries, n=3)
plot.ts(king_sma3)
king_sma8 <- SMA(kingstimeseries, n=8)
plot.ts(king_sma8)

# kpss.test() : Kwiatkowski-Phillips-Schmide-Shin
# 귀무가설 : 정상성 시계열이다.
# 대립가설 : 비정상성 시계열이다.
kpss.test(king_sma8)  # Stationarity : 안전성 테스트. / p-value가 0.05보다 크기에, 정상성 시계열이다.
# 차분
king_diff <- diff(kingstimeseries, differences = 1)
plot.ts(king_diff)
kpss.test(king_diff)  # 정상성을 가진 데이터

acf(king_diff, lag.max = 20)  # 첫 번째 lag에서 초과
acf(king_diff, lag.max = 20, plot=F)

# partial auto corelation function
pacf(king_diff, lag.max = 20)  # lag1, lag2, lag3에 대해, 초과
pacf(king_diff, lag.max = 20, plot=F)

#  ARIMA(p, d, q) => AR, 차분횟수, MA의 계수
auto.arima(kings)  # 추천 : ARIMA(0, 1, 1) : 비정상성을 가진 데이터에도 적용이 가능하다.
kingstimeseriesarima <- arima(kingstimeseries, order=c(0, 1, 1))  # 예측 모델
kingstimeseriesarima
?forecast
# h : Number of periods for forecasting
kingstimeseriesforecasts <- forecast(kingstimeseriesarima, h=5)  # 예측 함수 (predict이 아님)
kingstimeseriesforecasts
plot(kingstimeseriesforecasts)

# 문제
x = w = rnorm(300)
for(t in 2:300) x[t] = x[t-1] + w[t]
# 위의 데이터에 대해 시계열 데이터로 변환하고 정상성을 띄고 있는지 확인
(x.ts = ts(x))
kpss.test(x.ts)  # p-value : 0.01 => 비정상성
kpss.test(diff(x.ts))  # 정상성
tsdisplay(diff(x.ts))  # 차분한 데이터, ACF, PACF
# ACF, PACF : 데이터의 독립성 (시차 데이터가 서로 영향을 미치는가?)
# 점선 안에 있으면 서로 독립적, 벗어나있으면 독립적이지 않은 경우가 있다.
# ACF 차수 11에서, 독립적이지 않다.
# PACF : 10, 11이 독립적이지 않다.

# 정상성 확인
library(tseries)
class(AirPassengers)
(apts <- ts(AirPassengers, frequency = 12))
plot(apts)
# adf.test
# 귀무가설 : 비안정성이다.
# 대립가설 : stationary, 정상성이다.
adf.test(apts, alternative = "stationary", k=0)  # 0.01, 안정성
adf.test(diff(log(AirPassengers)), alternative="stationary", k=0)  # p-value = 0.01
kpss.test(apts)
auto.arima(AirPassengers)

# ARIMA(2,1,1)(0,1,0)  # seasonal : 계절적 변동성을 가진 데이터
(fit <- arima(log(AirPassengers), c(2,1,1), seasonal = list(order = c(0,1,0), period=12))) # 계절적 특성을 고려 (seasonal)
(pred <- predict(fit, n.ahead=10*12))
# 데이터에 로그를 취했기에, 역으로 exp을 취해주어야 복원된다.
# 지수 exp : 2값 지수가 취하는 일정비율 - 복리 계산 시 이자의 증가율 : 2.718(자연대수)
ts.plot(AirPassengers, 2.718^pred$pred, log="y", lty=c(1, 3))
par(mfrow=c(1,1))
# 제약(window)
air.model <- Arima(window(AirPassengers, end=1956+11/12), order=c(2, 1, 1),
                   seasonal=list(order=c(0,1,0), period=12), lambda = 0)
plot(forecast(air.model, h=48))  # 이후의 48개를 예측 
lines(AirPassengers)

# 문제
# WWWusage의 60기 까지만의 데이터를 분석하고 향후 10기에 대하여 예측
# (분석해보니 log가 상황이 더 좋아서, log로 변환)
# 비정상성 -> 정상성 시계열로 변환
## 내가 푼 답
?WWWusage  # 분당 동시접속수
class(WWWusage)  # ts
plot(WWWusage)
WWWusage

data <- ts(WWWusage[1:60])
auto.arima(log(data))
model <- Arima(log(data), order=c(0,2,0))
plot(forecast(model, h=10))
lines(data)

## 선생님 답
# ARIMA(p, d, q) => AR, 차분횟수, MA의 계수
length(WWWusage)
plot(WWWusage)
auto.arima(WWWusage)
# 귀무가설 : 정상성이다.
# 대립가설 : 비정상성이다.
kpss.test(WWWusage)  # 0.05377 => Stationarity (정상성)
# acf, pacf를 확인하는 이유? : 자기상관성
acf(WWWusage)
pacf(WWWusage)

kpss.test(log(WWWusage))
plot(log(WWWusage))
acf(log(WWWusage))
pacf(log(WWWusage))
auto.arima(log(WWWusage))

log(WWWusage) %>%
  Arima(order=c(1, 1, 1)) %>%
  forecast(h=20) %>%
  autoplot

data(gas)
str(gas)
plot(gas)
plot.ts(gas)
# 분해 시계열
?stl # Seasonal Decomposition of Time Series by Loess / 비선형 회귀에 의한 시계열데이터 계절 요소 분해
plot(stl(gas, s.window="periodic"))

kpss.test(gas)  # 0.01 / 대립가설 : 비정상성
acf(gas)  # 점선을 벗어남 -> 영향을 주고 있음. (독립적이지 않음)
pacf(gas)
gas.diff <- diff(log(gas))  # 로그 취하고 차분 -> 정상성을 가진 데이터로 변환함.
adf.test(gas.diff, alternative="stationary", k=0)  # 0.01
kpss.test(gas.diff)  # p-value = 0.1 / 안정적

acf(gas.diff)
pacf(gas.diff)
plot(gas.diff)
gas.ari <- auto.arima(gas.diff)
summary(gas.ari)  # ARIMA(0,0,1)(0,1,1)
fit <- arima(window(log(gas), end=1980), c(0,0,1),
             seasonal = list(order=c(0,1,1), period=12))
forres <- forecast(fit, h=100)
forres$method
forres$residuals  # 실제값 ~ 예측한 값의 차이
library(ggplot2)
autoplot(forres$residuals) + xlab("날짜") + ylab("잔차") +
  ggtitle("모델잔차")
autoplot(forres$residuals) + xlab("날짜")
ggAcf(forres$residuals) + ggtitle("잔차의 ACF")

# 자기상관성 : Box.test()
# 귀무가설 : 자기상관성이 0이다. (데이터들이 독립적으로 분포)
# 대립가설 : 자기상관성이 0이 아니다. (데이터들이 종속적으로 분포)
Box.test(forres$residuals, lag=10, fitdf=0)  # 2.2e-16 / 대립가설 (자기상관성이 0이 아님)
plot(forecast(fit, h=100))  # 100개 예측.
plot(2.718^forres$fitted)  # log 취하기


# 텍스트마이닝 (Text mining)
library(stringr)
# (대괄호:선택 / 중괄호:개수)
# str_extract() : 처음 패턴만 분리
str_extract("abcd12aaa33", "[0-9]{2}")  # [0-9]{2} : 정규 표현식 (패턴으로 비교) (대괄호:선택 / 중괄호:개수) 
str_extract_all("abcd12aaa33", "[0-9]{2}")

# if 비교문을 사용하는 것이 아닌, 패턴을 이용하여 데이터를 선택한다.
str <- 'hongkildong35lee45kang55안창호25'
(result <- str_extract_all(str, '[a-z]{3}'))  # a부터 z까지, 영문을 3자씩 추출하여 출력
(result <- str_extract_all(str, '[0-9]{2}'))
(result <- str_extract_all(str, '[가-히]{3}'))
nchar(str)  # 문자열 개수
length(str) # 문자열 길이

head(USArrests)  # 미국 50개 주(지역)의 데이터
(states = rownames(USArrests))
grep(pattern = "k", x=states)  # states 데이터 중 패턴 k 값을 가지고 있는 주의 번호는?
grep(pattern = "k", x=states, value=T)  # k가 포함되어 있는 데이터 직접출력
grep(pattern = "[ww]", x=states, value=T)

money = "$money" # $money라는 데이터
# sub / gsub
sub(pattern = "\\$", replacement="", x=money)  # 데이터 중 $를 찾아 지우기 ($는 특별한 의미가 있는 기호여서, \\를 붙여줘야 함) (대체)
gsub("\\d", "_", "the dandelion war 2010")  # d는 숫자, D는 숫자가 아닌 것 / 숫자를 찾아 "_"로 대체
gsub("\\w", "_", "the dandelion war 2010")  # w는 문자, W는 문자가 아닌 것 / 문자를 찾아 "_"로 대체
gsub(pattern = "[[:blank:]]", replacement = "", "the dandelion war 2010")  # 공백을 삭제

# 문제
data <- c("12.578.69486")
# 위의 데이터에서 "."을 삭제
gsub("\\.", replacement="", data)

lorem = "대한민국 만세, 모두다 하나"
str_sub(lorem, start=1, end=5)  # 1부터 5까지 문자 가져오기 (공백을 포함)
bad_text = c("This", " example ", "has several ")
str_trim(bad_text, side = "both")  # trim : 공백을 제거
str_pad("hola", width=7)  # pad : 공백 채우기 / "hola" 앞에 7칸의 공백 넣기
str_extract_all("abcd12aaa33", "\\d")  # "[1-9]{2}"
chr6 = "123한글나라456"
str_extract(chr6, "[가-흐]+")  # 한글만 추출

chr6 = "abdbsdsa 010-1234-5678 dasdasd"
pat <- "[0-9]{3}-[0-9]{4}-[0-9]{4}"
str_extract(chr6, pat)

fruits1 <- c(" 사과 한개", "배 두개", "바나나 세개 ")
str_replace(fruits1, "[개]", " 바구니")  # fruits1 데이터에서 '개'를 찾아 '바구니'로 바꾸기

shopinglist <- c("2017-10-19 수입3000원", "2017-10-20 수입14500원", "2017-10-21 수입2500원")
str_extract_all(shopinglist, "[0-9]{4}원", simplify=T)
str_replace_all(shopinglist, "-", "/")
str_extract_all(shopinglist, "[0-9]{4}[-][0-9]{2}[-][0-9]{2}", simplify=T)

# install.packages("tm")
library(tm)
data("crude")
# 역문서 빈도
tfidf=function(mat) {
  tf <- mat
  id = function(col){sum(!col==0)}
  idf <- log(nrow(mat)/apply(mat, 2, id))
  tfidf <- mat
  for(word in names(idf)){tfidf[, word] <- tf[, word] * idf[word]}
  return(tfidf)
}
class(crude)  # "VCorpus", "Corpus" ngcMatrix처럼 tm의 고유 포맷이다. (Document가 20개)
inspect(crude[1:3])
tdm <- TermDocumentMatrix(crude)[1:10, 1:20] 
# TermDocumentMatrix : 행이 단어(word), 열이 문서(document)이다.
# DocumentTermMatrix : 행이 문서이고, 열이 단어이다. / Sparsity 희소성 : 94% => 0이다.
Docs(tdm)
Terms(tdm)

tdm <- TermDocumentMatrix(crude,
                          control = list(removePunctuation = T,
                                         removeNumbers = T,
                                         stopwords = T, wordLengths = c(2, Inf)))
tdm
findFreqTerms(tdm, lowfreq = 10)  # 적어도 10번 이상 등장하는 단어를 출력
findFreqTerms(tdm, 2, 3)
findAssocs(tdm, 'dlrs', 0.25)  # 25% 관련성 있는 단어 
findMostFreqTerms(tdm)  # 문서별로 자주 등장하는 단어와 등장 횟수 출력.
(termFrequency <- rowSums(as.matrix(tdm)))  # 각 단어가 등장하는 횟수를 카운팅
(termFrequency <- colSums(as.matrix(tdm)))  # 각 문서에 들어있는 단어와, 등장횟수를 출력
(termFrequency <- subset(termFrequency, termFrequency>=10))

# install.packages("wordcloud")
library(wordcloud)
m <- as.matrix(tdm)
wordFreq <- sort(rowSums(m), decreasing = T)
set.seed(375)
pal <- brewer.pal(8, "Dark2")
wordcloud(words = names(wordFreq), freq = wordFreq, min.freq = 10, random.order = F,
          rot.per = .1, colors=pal)
