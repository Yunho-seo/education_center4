from django.forms import ModelForm
from .models import forum_Info
class forum_Info_Form(ModelForm):
    class Meta:
        model = forum_Info
        exclude = ()