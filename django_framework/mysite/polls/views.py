from django.shortcuts import render, get_object_or_404
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.views.generic.list import ListView
from .models import Question, Choice

def index(request):  # 첫번째 열
    # objects : 호출 객체 (= select * from Question), 날짜의 역순으로 5개의 질문 리스트 가져오기
    latest_question_list = Question.objects.all().order_by('-pub_date')[:5]
    # dict 형식으로 데이터를 넘김.
    context = {'latest_question_list': latest_question_list}
    return render(request, 'polls/index.html', context)

def detail(request, question_id):
    # web 404 에러는, 데이터가 없다는 의미이다.
    question = get_object_or_404(Question, pk=question_id)
    return render(request, 'polls/detail.html', {'question': question})

def results(request, question_id):
    question = get_object_or_404(Question, pk=question_id)
    return render(request, 'polls/result.html', {'question': question})

def vote(request, question_id):
    p = get_object_or_404(Question, pk=question_id)
    try:    # 클라이언트에서 선택한 번호가 있을 때 (postup 방식)
        selected_choice = p.choice_set.get(pk=request.POST['choice'])
    except(KeyError, Choice.DoesNotExist):  # 선택하지 않았을 때
        return render(request, 'polls/detail.html', {
            'question':p, 'error_message': "선택하지 않았습니다.",
        })
    else:
        selected_choice.votes += 1      # 선택 횟수를 추가
        selected_choice.save()  # update / 데이터베이스에 저장
        # 보안 때문에 (reverse('polls:results')) 처럼 사용
        return HttpResponseRedirect(reverse('polls:results', args=(p.id,)))