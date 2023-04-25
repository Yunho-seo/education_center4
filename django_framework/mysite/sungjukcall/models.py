from django.db import models
from django.urls import reverse
# 테이블과
class Sungjuk(models.Model):    # 클래스명이 테이블명
    # 제약조건을 지정
    # id = models.BigAutoField(primary_key = True)  # id가 생략되어 있음. / 값이 자동 증가, PK
    name = models.CharField("이름", max_length=50, unique=False)
    kor = models.IntegerField("국어", default=0)
    mat = models.IntegerField("수학", default=0)
    eng = models.IntegerField("영어", default=0)
    tot = models.IntegerField("총점", default=0)  # DB에 저장하지 않음 (실시간 계산)
    avg = models.FloatField("평균", default=0)    # DB에 저장하지 않음 (실시간 계산)

    def __str__(self):
        return self.name

    # @property 사용하여 총점과 평균을 실시간 계산하도록 한다.
    @property  # 자바에서는 어노테이션
    def tot(self):  # 변수와 같은 이름으로 함수를 저장 후 총점값을 계산하여 리턴.
        return self.kor + self.mat + self.eng
    @property
    def avg(self):
        return round((self.kor + self.mat + self.eng) / 3, 2)
    def get_absolute_url(self):
        return reverse('server_edit', kwargs={'pk': self.pk})

    # 메타(Meta) : 테이블에 대한 추가정보
    class Meta:     # 클래스에 대한 정보
        verbose_name = '성적'
        verbose_name_plural = '성적셋'
        ordering = ['name']     # 이름으로 정렬