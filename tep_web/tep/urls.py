from django.urls import path

from . import views

urlpatterns = [
    #path('', views.index, name='index'),
    path('paciente', views.registro_paciente, name='registro_paciente'),
    path('datos/<int:consulta_anonima>', views.datos_medicos, name='datos_medicos'),
    path('paciente/<int:id_paciente>', views.get_datos_paciente, name='get_datos_paciente'),
    path('historico_diagnosticos', views.historico_diagnosticos, name='historico_diagnosticos'),
]