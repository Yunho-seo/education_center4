"""
URL configuration for mysite project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path
from mysite import views
# path vs re_path(regular expression을 사용한 주소사용)
# urls 사용 => urlpatterns => path, re_path
urlpatterns = [
    path("admin/", admin.site.urls),
    re_path(r'^pandasgraph', views.pandasgraph, name='pandasgraph'),
    re_path(r'^$', views.HomeView.as_view(), name='home'),  # HomeView는 Class, 클래스인 경우 as_view()를 호출
    re_path(r'^polls/', include('polls.urls'))  # ^ : 맨 처음을 의미, regula expression (정규표현식)
]
