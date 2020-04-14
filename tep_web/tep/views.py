from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from .forms import PacienteForm, DiagnosticoForm
from .models import Paciente
import csv


csv_columns = ['genero', 'edad','bebedor','fumador','otra_enfermedad',
    'procedimiento_15dias','inmovilidad_inferior','viaje_prolongado','antecedentes_tep',
    'malignidad','disnea','dolor_toracico','tos','hemoptisis','disautonomicos','edema_inferior',
    'frec_respiratoria','so2','frec_cardiaca','pr_sistolica','pr_diastolica','fiebre','crepitos',
    'sibilancias','soplos','wbc','hb','plt','derrame']    

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
        if form.is_valid():
            csv_file = 'tep/CSV/input.csv'
            print('VALID')
            form.save()  

            csv_data = [form.cleaned_data]
            del csv_data[0]['paciente']
            print(csv_data)
            try:
                with open(csv_file, 'w') as csvfile:
                    writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
                    writer.writeheader()
                    for data in csv_data:
                        print(data)
                        writer.writerow(data)
            except IOError as e:
                print("I/O error", e)

    form = DiagnosticoForm()
    return render(request, 'tep/registro_diagnostico.html', {'form':form})


def get_datos_paciente(request, id_paciente):      
    if request.method == 'GET':            
        paciente = Paciente.objects.get(pk=id_paciente)
        return JsonResponse({'sexo': paciente.sexo, 'edad':paciente.edad})