from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from .forms import PacienteForm, DiagnosticoForm
from .models import Paciente
import csv
import rpy2.robjects as robjects
from rpy2.robjects import r


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
            form.save()
            csv_file = 'tep_web/tep/CSV/input.csv'            

            patient_dict = [form.cleaned_data]
            del patient_dict[0]['paciente']            

            for key in patient_dict[0]:
                attribute = patient_dict[0][key]
                if isinstance(attribute,bool):
                    if attribute:
                        patient_dict[0][key] = 1
                    else:
                        patient_dict[0][key] = 0
            
            try:
                with open(csv_file, 'w+') as csvfile:
                    writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
                    writer.writeheader()
                    for data in patient_dict:
                        writer.writerow(data)
            except IOError as e:
                print("I/O error", e)

            result = r['source']('/home/joan/Desktop/Tesis/tep_prediction/tep_web/tep/CSV/tep_predict.R')
            print("Predicción:",result[0][0][0])

    form = DiagnosticoForm()
    return render(request, 'tep/registro_diagnostico.html', {'form':form})


def get_datos_paciente(request, id_paciente):      
    if request.method == 'GET':            
        paciente = Paciente.objects.get(pk=id_paciente)
        return JsonResponse({'sexo': paciente.sexo, 'edad':paciente.edad})