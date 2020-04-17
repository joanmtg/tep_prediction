from django.shortcuts import render, redirect
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.core import serializers
from .forms import PacienteForm, DiagnosticoForm, DiagnosticoAnonimoForm
from .models import Paciente, Diagnostico
import csv, os, json
import rpy2.robjects as robjects
from rpy2.robjects import r
from tep_web.settings import CSV_AND_SCRIPTS_FOLDER
from django.db.models import Prefetch
import pytz
from tzlocal import get_localzone

csv_columns = ['genero', 'edad','bebedor','fumador','otra_enfermedad',
    'procedimiento_15dias','inmovilidad_inferior','viaje_prolongado','antecedentes_tep',
    'malignidad','disnea','dolor_toracico','tos','hemoptisis','disautonomicos','edema_inferior',
    'frec_respiratoria','so2','frec_cardiaca','pr_sistolica','pr_diastolica','fiebre','crepitos',
    'sibilancias','soplos','wbc','hb','plt','derrame', 'tep']    


def crear_csv(datos_formulario, archivo):

    if 'paciente' in datos_formulario[0]:    
        del datos_formulario[0]['paciente']            

    for key in datos_formulario[0]:
        attribute = datos_formulario[0][key]
        if isinstance(attribute,bool):
            if attribute:
                datos_formulario[0][key] = 1
            else:
                datos_formulario[0][key] = 0
    
    datos_formulario[0]['tep'] = 0
    
    try:
        with open(archivo, 'w+') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
            writer.writeheader()
            for data in datos_formulario:
                writer.writerow(data)
            return True
    except IOError as e:
        print("I/O error", e)
        return False

def registro_paciente(request):    
    if request.method == "POST":
        form = PacienteForm(request.POST)
        if form.is_valid():
            #print('VALID')
            form.save()    
            messages.success(request, "El paciente ha sido registrado correctamente")
            form = PacienteForm()
            #return redirect('/paciente')
        else:
            messages.error(request, "Por favor verificar los campos en rojo") 
        print(form.errors)
    else:   
        form = PacienteForm()

    return render(request, 'tep/registro_paciente.html', {'form':form})

def datos_medicos(request, consulta_anonima): 
    anonimo = consulta_anonima == 1

    if request.method == "POST":
        form = DiagnosticoForm(request.POST)  

        if anonimo:
            form = DiagnosticoAnonimoForm(request.POST)
            print(form)

        if form.is_valid():            
            if not anonimo:                
                form.save()
            csv_file =  CSV_AND_SCRIPTS_FOLDER + 'input.csv'
            patient_dict = [form.cleaned_data]
            csv_creado = crear_csv(patient_dict, csv_file)
            
            if csv_creado:
                result = r['source'](CSV_AND_SCRIPTS_FOLDER + 'tep_predict_NN.R')
                print("Predicción:",result[0][0][0])
                prediccion_NN = result[0][0][0] == 1.0  
                if not anonimo:
                    diagnostico = Diagnostico.objects.all().order_by('-pk')[0]                    
                    diagnostico.diagnostico_nn = prediccion_NN
                    diagnostico.save()                

                return render(request, 'tep/mostrar_resultados.html', {'prediccion_nn':prediccion_NN})
        else:
            messages.error(request, "Por favor verificar los campos en rojo")
        print(form.errors)
    else:        
        form = DiagnosticoForm()
        if anonimo:
            form = DiagnosticoAnonimoForm()

    return render(request, 'tep/registro_diagnostico.html', {'form':form, 'anonimo':anonimo})


def get_datos_paciente(request, id_paciente):      
    if request.method == 'GET':            
        paciente = Paciente.objects.get(pk=id_paciente)
        get_paciente = {'cedula': paciente.cedula, 'nombres': paciente.nombres,
                        'apellidos': paciente.apellidos, 'sexo': paciente.sexo,
                        'edad': paciente.edad}

        return JsonResponse({'paciente': get_paciente}) 


def historico_diagnosticos(request):

    diagnosticos = Diagnostico.objects.values('id', 'paciente', 'diagnostico_nn', 'fecha').order_by('-id')        
    process_data = list(diagnosticos)    
    data_diagnosticos = list()
        
    for diagnostico in process_data:            
        paciente = Paciente.objects.get(pk=diagnostico['paciente']) 
        get_diagnostico = {'id_diagnostico': diagnostico['id'],
                            'fecha' : diagnostico['fecha'].astimezone(get_localzone()).strftime("%m/%d/%Y, %H:%M:%S"),                          
                            'cedula': paciente.cedula, 
                            'nombres': paciente.nombres,
                            'apellidos': paciente.apellidos,
                            'sexo': 'Masculino' if paciente.sexo == 1 else 'Femenino',
                            'edad': paciente.edad,
                            'diagnostico_nn': 'SÍ' if diagnostico['diagnostico_nn'] else 'NO' }        
        data_diagnosticos.append(get_diagnostico)

    return render(request, 'tep/historico_diagnosticos.html', {'diagnosticos': json.dumps(data_diagnosticos)})