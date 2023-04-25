from django.shortcuts import render
from django.views.generic import TemplateView, ListView, DetailView
from django.views.generic.edit import CreateView, UpdateView, DeleteView
from django.urls import reverse_lazy
from .models import Sungjuk

# Sungjuk.object.all() 호출
class SungjukList(ListView):    # 모든 데이터를 확인
    model = Sungjuk
    # object_List : get_queryset(), 기본적으로 생성이 되어 있는 객체이다. # 데이터를 변경하고 싶으면 오버라이딩
    # get_template_names() : sungjuk_list.html이다. # 이름을 변경하고 싶으면, 오버라이딩
    template_name = 'sungjukcall/sungjuk_list.html'

class sungjukdetail(DetailView):    # 생성자가 PK를 받는다.
    # 생성자 오버로딩은 없음
    model = Sungjuk     # 기본 꼴
    field = ['name', 'kor', 'mat', 'eng', 'tot', 'avg']
    template_name = 'sungjukcall/detail.html'
    context_object_name = 'sungjuk'     # 실제 데이터를 담았을 때의 이름

# 한 사람의 데이터를 입력 : form을 사용한다.
# 입력 성공 이후
# form을 생성하고, formview를 이용하여 연결

# 테이블에 데이터를 입력하는 방법?
# form(submit) -> request 파싱 -> query 생성 -> 테이블에 저장
# model : form을 매핑 (데이터 수정(데이터가 바인딩(bind) 되어야 함), 데이터 삽입(공백 상태) 사용)
class SungjukCreate(CreateView):
    model = Sungjuk     # sungjuk_form.html
    fields = ['name', 'kor', 'mat', 'eng']  # 이름, 국어, 수학, 영어 점수만 입력받는다 / tot, avg는 불필요
    # Redirect
    success_url = reverse_lazy('sungjukcall:sungjuk_list')  # 입력 성공 시 전체 데이터를 확인하는 화면

# 입력(Create)과 다른 점?
# 수정을 하려면, 데이터를 채워서 클라이언트에 전송해야 한다.
# PK를 생성자에 초기화한다
class SungjukUpdate(UpdateView):
    model = Sungjuk
    fields = ['name', 'kor', 'mat', 'eng']
    success_url = reverse_lazy('sungjukcall:sungjuk_list')

# PK가 필요하다.
class SungjukDelete(DeleteView):
    model = Sungjuk
    success_url = reverse_lazy('sungjuk:sungjuk_list')