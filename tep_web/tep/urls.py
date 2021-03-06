from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('paciente', views.registro_paciente, name='registro_paciente'),
    path('datos/<int:consulta_anonima>/<int:id_paciente>', views.datos_medicos, name='datos_medicos'),
    path('paciente/<int:id_paciente>', views.get_datos_paciente, name='get_datos_paciente'),
    path('historico_diagnosticos', views.historico_diagnosticos, name='historico_diagnosticos'),
    path('paciente/update/<int:id_paciente>', views.actualizar_paciente,name='actualizar_paciente'),
    path('pacientes', views.lista_pacientes, name='lista_pacientes'),
    path('cargar_diagnostico_multiple', views.cargar_diagnostico_multiple, name='cargar_diagnostico_multiple'),
    path('diagnostico_multiple', views.diagnostico_multiple, name='diagnostico_multiple'),
    path('validacion_diagnosticos/<int:cod_operacion>', views.validacion_diagnosticos, name='validacion_diagnosticos'),

]