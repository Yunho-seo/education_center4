from django.urls import path
from polls import views
app_name = "polls"
urlpatterns = [
    path('', views.index, name='index'),
    path('<int:question_id>/', views.detail, name='detail'),  # 내부에서 사용하는 이름
    path('<int:question_id>/results/', views.results, name='results'),
    path('<int:question_id>/vote/', views.vote, name='vote'),
    # path('choice_graph/', views.choice_graph, name='choice_graph'),
]