from django.db import models

class forum_Info(models.Model):
    subject = models.CharField('제목', max_length=20)
    name = models.CharField('이름', max_length=20)
    story = models.TextField('내용')

    class Meta:
        verbose_name = '글쓴이'
        verbose_name_plural = '글쓴이들'
        ordering = ['name']
    def __str__(self):
        return '%s %s %s' % (self.subject, self.name, self.story)
    def save(self, *args, **kwargs): # 오버라이딩
        super(forum_Info, self).save(*args, **kwargs)