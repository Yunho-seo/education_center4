# 로그인 관리
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.core.exceptions import PermissionDenied
from django.shortcuts import get_object_or_404, redirect, render

from .forms import Addr_Info_Form
from .models import Addr_Info
def addr_info_read(request):
    addr_infos = Addr_Info.objects.all() # default manager, ORM
    context = {'addr_infos': addr_infos}
    return render(request, 'addressbook/addr_info_list.html', context)
def addr_info_create(request):
    if request.method == 'POST': # 클라이언트에서 데이터가 입력
        form = Addr_Info_Form(data=request.POST)
        if form.is_valid(): # 데이터가 정당한지
            bookmark = form.save(commit=False) # 커밋없이 저장 (메모리에서 작업)
            bookmark.save()
            form.save_m2m()
            return redirect('addressbook:addressbook_addr_info_read')
    else: # get인 경우 폼만 전달
        form = Addr_Info_Form()
    context = {'form':form, 'create': True}
    return render(request, 'addressbook/form.html', context)
def addr_info_update(request, pk):
    addr_info = get_object_or_404(Addr_Info, pk=pk)
    if request.method == 'POST': # 수정 데이터가 form을 통해서 업로드
        form = Addr_Info_Form(instance=addr_info, data=request.POST)
        if form.is_valid(): # 데이터타입 해당되는 데이터인지
            form.save()
            return redirect('addressbook:addressbook_addr_info_read')
    else: # get 이면 수정하기 위해서 데이터를 바인딩해서 클라이언트로 송신
        form = Addr_Info_Form(instance=addr_info)
    context = {'form': form, 'create': False}
    return render(request, 'addressbook/form.html', context)
# 함수의 포맷이기 때문에 request는 형식을 유지해야 함.
def addr_info_delete(request, pk):
    addr_info = get_object_or_404(Addr_Info, pk=pk)
    if pk is not None:
        addr_info.delete()
    return redirect('addressbook:addressbook_addr_info_read')