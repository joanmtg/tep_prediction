from django.shortcuts import render, redirect, reverse
from django.http import HttpResponse, JsonResponse
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core import serializers
from django.contrib.auth import login, logout, authenticate
from .forms import PacienteForm, DiagnosticoForm, DiagnosticoAnonimoForm, ActualizarPacienteForm
from .models import Paciente, Diagnostico
import csv, os, json
import rpy2.robjects as robjects
from rpy2.robjects import r
from tep_web.settings import CSV_AND_SCRIPTS_FOLDER
import pytz
from tzlocal import get_localzone

#Columnas del CSV temporal a crear con la información de los pacientes a diagnosticar

csv_columns = ['genero', 'edad','bebedor','fumador','otra_enfermedad',
    'procedimiento_15dias','inmovilidad_inferior','viaje_prolongado','antecedentes_tep',
    'malignidad','disnea','dolor_toracico','tos','hemoptisis','disautonomicos','edema_inferior',
    'frec_respiratoria','so2','frec_cardiaca','pr_sistolica','pr_diastolica','fiebre','crepitos',
    'sibilancias','soplos','wbc','hb','plt','derrame', 'tep']


def crear_csv(datos_formulario, archivo):

    """
    Función crear_csv

    Parámetros:
    datos_formulario    Datos ingresados de pacientes a diagnosticar
    archivo             Ruta del archivo CSV a crear

    """

    #Procesamiento de los datos
    for datos in datos_formulario:
        datos['tep'] = 0
        #El atributo "paciente" (codigo paciente) no es relevante para el diagnóstico
        if 'paciente' in datos:
            del datos['paciente']

        # True y False --> 1, 0
        for key in datos:
            attribute = datos[key]
            if isinstance(attribute,bool):
                if attribute:
                    datos[key] = 1
                else:
                    datos[key] = 0

    #Escritura de los datos procesados en el archivo CSV
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

# Renderiza la página de landing 'index'
def index(request):
    return render(request, 'tep/index.html')

@login_required(login_url="login")
def registro_paciente(request):

    """
    Vista de método POST para registro de un paciente
    """

    if request.method == "POST":
        diagnosticar = 'btn_guardar_diagnosticar' in request.POST
        form = PacienteForm(request.POST)
        if form.is_valid():
            paciente = form.save()
            paciente.medico = request.user
            paciente.save()
            if diagnosticar:
                messages.success(request, "El paciente ha sido registrado correctamente. Ingrese sus datos médicos")
                return redirect(reverse('datos_medicos', args=[0, paciente.pk]))
            else:
                form = PacienteForm()
                messages.success(request, "El paciente ha sido registrado correctamente")
                return render(request, 'tep/registro_paciente.html', {'form':form})

        else:
            messages.error(request, "Por favor verificar los campos en rojo")
            print(form.errors)
    else:
        form = PacienteForm()

    return render(request, 'tep/registro_paciente.html', {'form':form})

@login_required(login_url="login")
def actualizar_paciente(request, id_paciente):

    """
    Vista de método POST para renderizar y manejar la actualización de los datos un paciente

    Parámetros:
    id_paciente: numero id del paciente a actualizar

    """

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

@login_required(login_url="login")
def datos_medicos(request, consulta_anonima, id_paciente):

    """
    Vista de método POST para renderizar y manejar el ingreso de los datos médicos de un paciente,
    así como también el procesamiento y predicción del diagnóstico

    Parámetros:

    consulta_anonima:
        1: Se guarda la información del paciente asociada al diagnóstico
        0: No se guarda la información mencionada

    id_paciente:
        Número id del paciente
        0: cuando es anónimo
        cualquier otro número: hace referencia a un paciente

    """

    anonimo = consulta_anonima == 1
    cargar_paciente = id_paciente != 0

    if request.method == "POST":
        #Creacion del formulario de ingreso de datos médicos con los datos enviados
        if anonimo:
            form = DiagnosticoAnonimoForm(request.POST)
        else:
            form = DiagnosticoForm(request.POST)
            #Cargar pacientes asociados al médico
            form.fields['paciente'].queryset = Paciente.objects.filter(medico=request.user.id)

        if form.is_valid():
            nombre_paciente = 'Anónimo'
            if not anonimo:
                #se guardan los datos médicos en la BD
                form.save()
                nombre_paciente = str(form.cleaned_data['paciente'])

            csv_file =  CSV_AND_SCRIPTS_FOLDER + 'input.csv'
            patient_dict = [form.cleaned_data]
            csv_creado = crear_csv(patient_dict, csv_file)

            if csv_creado:

                #Realizar predicción con el script de R
                result = r['source'](CSV_AND_SCRIPTS_FOLDER + 'tep_predict_NN.R')
                prediccion_NN = result[0][0][0] == 1.0
                if not anonimo:
                    #Guardar diagnóstico calculad en la BD
                    diagnostico = Diagnostico.objects.all().order_by('-pk')[0]
                    diagnostico.diagnostico_nn = prediccion_NN
                    diagnostico.save()

                #Se renderiza el template con los resultados obtenidos
                return render(request, 'tep/mostrar_resultados.html', {'prediccion_nn':prediccion_NN,
                                                                    'id_paciente': id_paciente,
                                                                    'nombre_paciente': nombre_paciente})
        else:
            #El formulario sólo puede ser inválido en caso de no haber cargado un paciente automáticamente
            if not cargar_paciente:
                messages.error(request, "Por favor verificar los campos en rojo")
                print(form.errors)
    else:
        #Se crea una instancia vacía del formulario requerido
        if anonimo:
            form = DiagnosticoAnonimoForm()
        else:
            form = DiagnosticoForm()
            form.fields['paciente'].queryset = Paciente.objects.filter(medico=request.user.id)

    return render(request, 'tep/registro_diagnostico.html', {'form':form, 'anonimo':anonimo,
                                                            'id_paciente':id_paciente})

@login_required(login_url="login")
def get_datos_paciente(request, id_paciente):

    """
    Vista de método GET para obtener la información de un paciente según su id
    """

    if request.method == 'GET':
        paciente = Paciente.objects.get(pk=id_paciente)
        get_paciente = {'cedula': paciente.cedula, 'nombres': paciente.nombres,
                        'apellidos': paciente.apellidos, 'sexo': paciente.sexo,
                        'edad': paciente.edad}

        return JsonResponse({'paciente': get_paciente})

@login_required(login_url="login")
def historico_diagnosticos(request):

    """
        Vista que se encarga de cargar y renderizar la página de histórico de diagnósticos
    """

    current_user = request.user

    #Se cargan los diagnósticos asociados al médico logueado en el sistema desde la BD
    diagnosticos = Diagnostico.objects.filter(paciente__medico=request.user.id).values('id', 'paciente', 'diagnostico_nn', 'fecha', 'edad', 'genero', 'aprobado').order_by('-id')
    process_data = list(diagnosticos)
    data_diagnosticos = list()

    for diagnostico in process_data:

        #TODO: Agregar y validar aprobación de los otros dos modelos
        #Se validan las aprobaciones del diagnóstico (si existen)
        aprobado = 'Sin valoración'
        if diagnostico['aprobado'] is not None:
            aprobado =  'SÍ' if diagnostico['aprobado'] else 'NO'

        #Se carga la información del paciente
        paciente = Paciente.objects.get(pk=diagnostico['paciente'])

        #Se preparan y se combinan el paciente unto con su diagnóstico asociado
        get_diagnostico = {'id_diagnostico': diagnostico['id'],
                            'fecha' : diagnostico['fecha'].astimezone(get_localzone()).strftime("%m/%d/%Y, %H:%M:%S"),
                            'cedula': paciente.cedula,
                            'nombres': paciente.nombres,
                            'apellidos': paciente.apellidos,
                            'sexo': 'Masculino' if diagnostico['genero'] == 1 else 'Femenino',
                            'edad': diagnostico['edad'],
                            'diagnostico_nn': 'Detectado' if diagnostico['diagnostico_nn'] else 'No detectado',
                            'aprobado': aprobado}
        data_diagnosticos.append(get_diagnostico)

    return render(request, 'tep/historico_diagnosticos.html', {'diagnosticos': json.dumps(data_diagnosticos)})

@login_required(login_url="login")
def lista_pacientes(request):

    """
    Vista que carga y renderiza la lista de pacientes asociados al médico logueado
    """

    pacientes = Paciente.objects.filter(medico=request.user.id).values('pk', 'cedula', 'nombres', 'apellidos',
                                        'sexo', 'fecha_nacimiento')
    list_pacientes = list(pacientes)
    data = list()

    for paciente in list_pacientes:
        data.append({'id':paciente['pk'],
                    'cedula': paciente['cedula'],
                    'nombres': paciente['nombres'],
                    'apellidos': paciente['apellidos'],
                    'sexo': 'Masculino' if paciente['sexo'] == 1 else 'Femenino',
                    'fecha_nacimiento': paciente['fecha_nacimiento'].strftime("%m/%d/%Y")})

    return render(request, 'tep/lista_pacientes.html', {'pacientes': json.dumps(data)})

@login_required(login_url="login")
def cargar_diagnostico_multiple(request):

    """
    Vista que prepara y renderiza la página de diagnóstico múltiple, en la cual
    se pueden ingresar los datos médicos de varios pacientes al tiempo
    """

    fields_dict = ['id','value']

    #Campos categóricos
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

    #Campos booleanos
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

    pacientes = Paciente.objects.filter(medico=request.user.id)
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
                          'textField': 'value',
                          'width': 200 if len(field.verbose_name) >= 50 else 140 if len(field.verbose_name) >=15 else 120
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
                          'validate': 'required',
                          'width': 200 if len(field.verbose_name) >= 50 else 140 if len(field.verbose_name) >=15 else 120

            }
            lista_atributos.append(field_data)


    return render(request, 'tep/diagnostico_multiple.html',{'lista_atributos': json.dumps(lista_atributos),
                                                         'pacientes': json.dumps(pacientes)})

@login_required(login_url="login")
def diagnostico_multiple(request):

    """
    Vista que recibe los datos médicos de varios pacientes, realiza su diagnóstico
    y retorna un objeto JSON con los resultados para que estos sean procesados en la
    página mostrada al usuario

    """

    if request.method == 'POST':
        load_diagnosticos = request.POST.getlist('pacientes')
        diagnosticos = json.loads(load_diagnosticos[0])

        #Se elimina el diagnostico de ejemplo de la lista
        diagnosticos.pop(0)

        #Lista para guardar temporalmente la relacion diagnosticos - pacientes
        diagnosticos_pacientes = list()

        #Se guardan los datos médicos en la base de datos
        for diagnostico in diagnosticos:
            if diagnostico['paciente'] != 0:
                diagnostico['paciente'] = Paciente.objects.get(pk=diagnostico['paciente'])
                diag_save = Diagnostico(**diagnostico)
                diag_save.save()
                diagnosticos_pacientes.append({'id_diagnostico': diag_save.id,
                                                'paciente': str(diag_save.paciente)})
            else:
                diagnosticos_pacientes.append({'id_diagnostico': 0,
                                                'paciente': 'Anónimo'})

        #Se crea el csv con datos micos a ser utilizados por el script de predicción en R
        csv_file =  CSV_AND_SCRIPTS_FOLDER + 'input.csv'
        patient_dict = diagnosticos
        csv_creado = crear_csv(diagnosticos, csv_file)

        for (diagnostico, diag_paciente) in zip(diagnosticos, diagnosticos_pacientes):
            diagnostico['id_diagnostico'] = diag_paciente['id_diagnostico']
            diagnostico['paciente'] = diag_paciente['paciente']
            diagnostico['genero'] = 'Masculino' if diagnostico['genero'] == 1 else 'Femenino'

        if csv_creado:
            result = r['source'](CSV_AND_SCRIPTS_FOLDER + 'tep_predict_NN.R')
            predicciones = result[0][0]
            for (prediccion, diagnostico) in zip(predicciones, diagnosticos):
                prediccion = prediccion == 1.0
                diagnostico['prediccion'] = 'Detectado' if prediccion else 'No detectado'

                id_diagnostico = diagnostico['id_diagnostico']
                #Si no es un diagnostico anónimo, se guarda la predicción
                #correspondiente en la BD
                if id_diagnostico != 0:
                    diagn_save = Diagnostico.objects.get(pk=id_diagnostico)
                    diagn_save.diagnostico_nn = prediccion
                    diagn_save.save()
        return JsonResponse({'diagnosticos': json.dumps(diagnosticos)})


@login_required(login_url="login")
def validacion_diagnosticos(request, cod_operacion):

    """
    Vista de método POST que permite realizar la aprobación/desaprobación de una lista de diagnósticos
    que se recibe dentro de la request, guardando dicha valoración en la BD

    Parámetro:
        cod_operacion:
        1: aprobar
        0: desaprobar

    """

    #TODO La validación debe estar separada por modelo de predicción: NN, SVM, RandomForest

    if request.method == 'POST':
        load_diagnosticos = request.POST.getlist('diagnosticos')
        ids_diagnosticos = json.loads(load_diagnosticos[0])

        for id_diag in ids_diagnosticos:
            diagnostico = Diagnostico.objects.get(pk=id_diag)
            diagnostico.aprobado = cod_operacion == 1
            diagnostico.save()

    return JsonResponse({'operacion': True})