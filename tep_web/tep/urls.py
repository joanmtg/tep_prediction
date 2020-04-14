from django.urls import path

from . import views

urlpatterns = [
    #path('', views.index, name='index'),
    path('paciente', views.registro_paciente, name='registro_paciente'),
    path('datos', views.datos_medicos, name='datos_medicos'),
    path('paciente/<int:id_paciente>', views.get_datos_paciente, name='get_datos_paciente')
]