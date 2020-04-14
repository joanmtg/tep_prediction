from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from .forms import PacienteForm, DiagnosticoForm
from .models import Paciente
#import csv

def registro_paciente(request):    
    if request.method == "POST":
        form = PacienteForm(request.POST)
        if form.is_valid():
            print('VALID')
            form.save()                     

    form = PacienteForm()
    return render(request, 'tep/registro_paciente.html', {'form':form})

def datos_medicos(request): 
    if request.method == "POST":
        form = DiagnosticoForm(request.POST)
        print(form)
        if form.is_valid():
            print('VALID')
            form.save()             
    form = DiagnosticoForm()
    return render(request, 'tep/registro_diagnostico.html', {'form':form})


def get_datos_paciente(request, id_paciente):      
    if request.method == 'GET':            
        paciente = Paciente.objects.get(pk=id_paciente)
        return JsonResponse({'sexo': paciente.sexo, 'edad':paciente.edad})