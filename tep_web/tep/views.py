from django.shortcuts import render
from django.http import HttpResponse
from .forms import PacienteForm, DiagnosticoForm

def index(request):                     
    return render(request, 'tep/index.html')

def registro_paciente(request):    
    if request.method == "POST":
        form = PacienteForm(request.POST)
        if form.is_valid():
            form.save()                     

    form = PacienteForm()
    return render(request, 'tep/registro_paciente.html', {'form':form})

def datos_medicos(request):    
    if request.method == "POST":
        form = DiagnosticoForm(request.POST)
        if form.is_valid():
            form.save()                     

    form = DiagnosticoForm()
    return render(request, 'tep/registro_diagnostico.html', {'form':form})
