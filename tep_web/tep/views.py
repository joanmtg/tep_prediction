from django.shortcuts import render, redirect, reverse
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.core import serializers
from .forms import PacienteForm, DiagnosticoForm, DiagnosticoAnonimoForm, ActualizarPacienteForm
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
    
    for datos in datos_formulario:
        datos['tep'] = 0
        if 'paciente' in datos:
            del datos['paciente']

        for key in datos:
            attribute = datos[key]
            if isinstance(attribute,bool):
                if attribute:
                    datos[key] = 1
                else:
                    datos[key] = 0
        
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
            paciente = form.save()    
            messages.success(request, "El paciente ha sido registrado correctamente. Ingrese sus datos médicos")
            return redirect(reverse('datos_medicos', args=[0, paciente.pk]))
        else:
            messages.error(request, "Por favor verificar los campos en rojo") 
            print(form.errors)
    else:   
        form = PacienteForm()

    return render(request, 'tep/registro_paciente.html', {'form':form})


def actualizar_paciente(request, id_paciente):    

    if request.method == "POST":
        paciente = Paciente.objects.get(pk=id_paciente)
        form = ActualizarPacienteForm(request.POST, instance=paciente)
        if form.is_valid():
            form.save()    
            messages.success(request, "El paciente ha sido actualizado correctamente")
            form = ActualizarPacienteForm()
        else:
            messages.error(request, "Por favor verificar los campos en rojo") 
            print(form.errors)
    else:
        paciente = Paciente.objects.get(pk=id_paciente)
        form = ActualizarPacienteForm(instance=paciente)

    return render(request, 'tep/registro_paciente.html', {'form':form})


def datos_medicos(request, consulta_anonima, id_paciente): 
    anonimo = consulta_anonima == 1
    cargar_paciente = id_paciente != 0

    if request.method == "POST":
        if anonimo:
            form = DiagnosticoAnonimoForm(request.POST)
        else:
            form = DiagnosticoForm(request.POST)

        if form.is_valid():  
            nombre_paciente = 'Anónimo'              
            if not anonimo:     
                form.save()                         
                nombre_paciente = str(form.cleaned_data['paciente'])

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

                return render(request, 'tep/mostrar_resultados.html', {'prediccion_nn':prediccion_NN,
                                                                    'id_paciente': id_paciente,
                                                                    'nombre_paciente': nombre_paciente})
        else:
            if not cargar_paciente:
                messages.error(request, "Por favor verificar los campos en rojo")
                print(form.errors)
    else:        
        if anonimo:
            form = DiagnosticoAnonimoForm()
        else:
            form = DiagnosticoForm()

    return render(request, 'tep/registro_diagnostico.html', {'form':form, 'anonimo':anonimo,
                                                            'id_paciente':id_paciente})


def get_datos_paciente(request, id_paciente):      
    if request.method == 'GET':            
        paciente = Paciente.objects.get(pk=id_paciente)
        get_paciente = {'cedula': paciente.cedula, 'nombres': paciente.nombres,
                        'apellidos': paciente.apellidos, 'sexo': paciente.sexo,
                        'edad': paciente.edad}

        return JsonResponse({'paciente': get_paciente}) 


def historico_diagnosticos(request):

    diagnosticos = Diagnostico.objects.values('id', 'paciente', 'diagnostico_nn', 'fecha', 'edad', 'genero').order_by('-id')
    process_data = list(diagnosticos)    
    data_diagnosticos = list()
        
    for diagnostico in process_data:            
        paciente = Paciente.objects.get(pk=diagnostico['paciente']) 
        get_diagnostico = {'id_diagnostico': diagnostico['id'],
                            'fecha' : diagnostico['fecha'].astimezone(get_localzone()).strftime("%m/%d/%Y, %H:%M:%S"),                          
                            'cedula': paciente.cedula, 
                            'nombres': paciente.nombres,
                            'apellidos': paciente.apellidos,
                            'sexo': 'Masculino' if diagnostico['genero'] == 1 else 'Femenino',
                            'edad': diagnostico['edad'],
                            'diagnostico_nn': 'SÍ' if diagnostico['diagnostico_nn'] else 'NO' }        
        data_diagnosticos.append(get_diagnostico)

    return render(request, 'tep/historico_diagnosticos.html', {'diagnosticos': json.dumps(data_diagnosticos)})

def lista_pacientes(request):    
    pacientes = Paciente.objects.values('pk', 'cedula', 'nombres', 'apellidos',
                                        'sexo', 'fecha_nacimiento')    
    list_pacientes = list(pacientes)
    print(len(list_pacientes))
    data = list()

    for paciente in list_pacientes:
        data.append({'id':paciente['pk'],
                    'cedula': paciente['cedula'], 
                    'nombres': paciente['nombres'],
                    'apellidos': paciente['apellidos'],
                    'sexo': 'Masculino' if paciente['sexo'] == 1 else 'Femenino',
                    'fecha_nacimiento': paciente['fecha_nacimiento'].strftime("%m/%d/%Y")})      
                
    return render(request, 'tep/lista_pacientes.html', {'pacientes': json.dumps(data)})

def cargar_diagnostico_multiple(request):
    fields_dict = ['id','value']
    fields_select = ['frec_respiratoria',
                'so2',
                'frec_cardiaca',
                'pr_sistolica',
                'pr_diastolica',
                'soplos',
                'wbc',
                'hb',
                'plt',
                'derrame'
        ]

    fields_boolean = ['bebedor',
                'fumador',
                'otra_enfermedad',
                'procedimiento_15dias',
                'inmovilidad_inferior',
                'viaje_prolongado',
                'antecedentes_tep',
                'malignidad',
                'disnea',
                'dolor_toracico',
                'tos',
                'hemoptisis',
                'disautonomicos',
                'edema_inferior',
                'fiebre',
                'crepitos',
                'sibilancias']   
    
    lista_atributos = list()

    # Creación de choices con los pacientes existentes en la BD

    pacientes = Paciente.objects.all()
    anonimo = (0, "Paciente anónimo")
    lista_pacientes = () + (anonimo,) 
    
    for paciente in pacientes:
        paciente_choices = (paciente.id, str(paciente))
        lista_pacientes += (paciente_choices,)          
    
    pacientes = [dict(zip(fields_dict, d)) for d in lista_pacientes]
    

    #Se obtienen los campos del modelo Diagnostico con sus propiedades respectivas
    fields = Diagnostico._meta.get_fields()

    # Se crean y agregan los campos booleanos a la lista de atributos

    for field in fields:
        if field.name in fields_boolean:
            field_data = {'name':field.name,
                          'title': field.verbose_name.capitalize(),
                          'type': 'checkbox',
                          'valueField': 'id',
                          'textField': 'value'
            }
            lista_atributos.append(field_data)

    # Se crean y agregan los campos categóricos a la lista de atributos

    for field in fields:
        if field.name in fields_select:
            choices_fields = [dict(zip(fields_dict, d)) for d in field.choices]

            field_data = {'name':field.name,
                          'title': field.verbose_name.capitalize(),
                          'type': 'select',
                          'items': choices_fields,                          
                          'valueField': 'id',
                          'textField': 'value',
                          'validate': 'required'

            }
            lista_atributos.append(field_data)


    return render(request, 'tep/diagnostico_multiple.html',{'lista_atributos': json.dumps(lista_atributos),
                                                         'pacientes': json.dumps(pacientes)})

#@csrf_protect
def diagnostico_multiple(request):

    if request.method == 'POST':
        load_diagnosticos = request.POST.getlist('pacientes')
        diagnosticos = json.loads(load_diagnosticos[0])        

        diagnosticos.pop(0)

        for diagnostico in diagnosticos:            
            if diagnostico['paciente'] != 0:
                diagnostico['paciente'] = Paciente.objects.get(pk=diagnostico['paciente'])
                print(diagnostico)
                diag_save = Diagnostico(**diagnostico)
                #diagnostico['id'] = 
                diag_save.save()           


        csv_file =  CSV_AND_SCRIPTS_FOLDER + 'input.csv'
        patient_dict = diagnosticos
        csv_creado = crear_csv(diagnosticos, csv_file)
        
        if csv_creado:
            result = r['source'](CSV_AND_SCRIPTS_FOLDER + 'tep_predict_NN.R')
            print("Predicción:",result)
            """ prediccion_NN = result[0][0][0] == 1.0  
            if not anonimo:
                diagnostico = Diagnostico.objects.all().order_by('-pk')[0]                    
                diagnostico.diagnostico_nn = prediccion_NN
                diagnostico.save()  """

    
    return JsonResponse({'result':True})
                                                