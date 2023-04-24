from django.shortcuts import render, get_object_or_404
from django.views.generic.base import TemplateView

class HomeView(TemplateView):
    template_name = 'home.html'
    def get_context_data(self, **kwargs):
        context = super(HomeView, self).get_context_data(**kwargs)
        return context

# 실시간으로 이미지 만들기
import matplotlib # 시각화 패키지
matplotlib.use('Agg') # canvas에 접근하는 cache
import matplotlib.pyplot as plt # 출력공간
from django.http import HttpResponse
import numpy as np # 선형대수
import pandas as pd # Dataframe 이질적인 데이터를 담는 그릇
import io # 입출력을 제어
from matplotlib.backends.backend_agg import FigureCanvasAgg
def pandasgraph(request):
    # 이미지 사이즈를 결정, dot per inch 해상도를 결정
    fig=plt.figure(figsize=(6, 4.5), dpi=80, facecolor='w', edgecolor='w')
    ax=fig.add_subplot(111) # 화면을 분할 (행 , 열, 해당번호)
    # pandas : 시계열 데이터를 다룸
    f=pd.DataFrame({'y':np.random.randn(10), 'z':np.random.randn(10)},
                   index=pd.period_range('1-2000', periods=10))
    f.plot(ax=ax) # 도화지를 생성 -> 바플롯
    buf = io.BytesIO() # 임시버퍼
    canvas = FigureCanvasAgg(fig) # canvas는 웹에서 이미지를 그리는 공간 (vector)
    canvas.print_png(buf)
    fig.clear() # 도화를 정리
    plt.close('all')

    response=HttpResponse(buf.getvalue(), content_type='image/png')
    response['Content-Length'] = str(len(response.content))
    return response

# 이름, 국어, 영어, 수학 출력하는 app을 작성하여 제출하시오 (mail, 이름_날짜)