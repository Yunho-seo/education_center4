from django.forms import ModelForm
from .models import Addr_Info
class Addr_Info_Form(ModelForm):
    class Meta:
        model = Addr_Info # inputbox로 입력할 수 있도록 자동 생성
        exclude = ()