from django.urls import path
from sungjukcall import views
from django.urls import path

app_name = 'sungjukcall'
urlpatterns = [
    path('', views.SungjukList.as_view(), name='sungjuk_list'),
    path('new', views.SungjukCreate.as_view(), name='sungjuk_new'),
    path('detail/<int:pk>)', views.sungjukdetail.as_view(), name='sungjuk_detail'),
    path('edit/<int:pk>)', views.SungjukUpdate.as_view(), name='sungjuk_edit'),
    path('delete/<int:pk>)', views.SungjukDelete.as_view(), name='sungjuk_delete')
]