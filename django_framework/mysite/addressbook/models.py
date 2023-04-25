from django.db import models

class Addr_Info(models.Model):
    name = models.CharField('이름', max_length=20)
    age = models.IntegerField('나이')
    addr = models.TextField('주소')

    class Meta:
        verbose_name = '개인주소'
        verbose_name_plural = '주소록'
        ordering = ['name']
    def __str__(self):
        return '%s (%d) : %s' % (self.name, self.age, self.addr)
    def save(self, *args, **kwargs): # 오버라이딩
        super(Addr_Info, self).save(*args, **kwargs)