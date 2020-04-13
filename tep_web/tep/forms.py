from django import forms
from .models import Paciente, Diagnostico

class PacienteForm(forms.ModelForm):
    class Meta:
        model = Paciente
        fields =  '__all__'

class DiagnosticoForm(forms.ModelForm):
    class Meta:
        model = Diagnostico
        fields = '__all__'
