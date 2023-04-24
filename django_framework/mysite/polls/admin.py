from django.contrib import admin
from .models import Question, Choice

class Choiceinline(admin.TabularInline):    # 질문에 대한 응답 개수가 옆으로 출력(표시)된다.
    model = Choice
    extra = 3
# 관리자만 입력이 가능하다 (질문 + 응답 선택)
class QuestionAdmin(admin.ModelAdmin):      # 관리자에서 사용하는 테이블 형식
    fieldsets = [
        ('Question Statement', {'fields': ['question_text']}),
        ('Date Information', {'fields':['pub_date'], 'classes':['collapse']}),
    ]
    inlines = [Choiceinline]    # 선택어도 같이 입력 형태로 함
    list_display = ('question_text', 'pub_date')
    list_filter = ['pub_date']          # 날짜 지정
    search_fields = ['question_text']   # 검색

# 관리자 페이지에 등록
admin.site.register(Question, QuestionAdmin)
admin.site.register(Choice)