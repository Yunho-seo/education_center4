from django.urls import path
from forum import views

app_name = "forum"
urlpatterns = [
    path('create/', views.forum_info_create, name='forum_forum_info_create'),
    path('', views.forum_info_read, name='forum_forum_info_read'),
    path('update/<int:pk>/', views.forum_info_update, name='forum_forum_info_update'),
    path('delete/<int:pk>/', views.forum_info_delete, name='forum_forum_info_delete'),
]