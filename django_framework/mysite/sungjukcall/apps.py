from django.apps import AppConfig

class SungjukcallConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "sungjukcall"

# 장고는 apps 로 구성된다.
# python manage.py startapp sungjukcall
# models(DB 테이블 생성), views(action : model + templates), urls(urls + acti ~)
# MVT + urls
# view가 발달
    # CreateView, DetailView, UpdateView, DeleteView, FormView
    # class 내부에 기본적으로 동작하는 함수들이 자동으로 호출
# model 정의 -> python manage.py makemigrations ~
#           -> python manage.py migrate ~