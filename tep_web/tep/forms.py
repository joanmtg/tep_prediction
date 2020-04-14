from django import forms
from .models import Paciente, Diagnostico

class PacienteForm(forms.ModelForm):
    class Meta:
        model = Paciente
        fields =  '__all__'

class DiagnosticoForm(forms.ModelForm):
    class Meta:
        model = Diagnostico
        fields = ['paciente',
                'genero',
                'edad',
                'bebedor',
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
                'sibilancias',
                'frec_respiratoria',
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
    """ def __init__(self, *args, **kwargs): 
        super(DiagnosticoForm, self).__init__(*args, **kwargs)                       
        self.fields['genero'].disabled = True
        self.fields['edad'].disabled = True """
    
