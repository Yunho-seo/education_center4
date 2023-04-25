from sungjukcall import views
from django.urls import path
from addressbook import views
app_name = "addressbook"
urlpatterns = [
    path('create/', views.addr_info_create, name='addressbook_addr_info_create'),
    path('', views.addr_info_read, name='addressbook_addr_info_read'),
    path('update/<int:pk>/', views.addr_info_update, name='addressbook_addr_info_update'),
    path('delete/<int:pk>/', views.addr_info_delete, name='addressbook_addr_info_delete'),
]