from django.shortcuts import render
from django.http import HttpResponse
from .forms import PacienteForm


def index(request):    
    if request.method == "POST":
        form = PacienteForm(request.POST)
        if form.is_valid():
            form.save()                     

    form = PacienteForm()
    return render(request, 'tep/index.html', {'form':form})
