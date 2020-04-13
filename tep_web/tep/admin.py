from django.contrib import admin
from .models import Paciente, Diagnostico

admin.site.register(Paciente)
admin.site.register(Diagnostico)
